require File.dirname(__FILE__) + '/../spec_helper.rb'

describe Bandsintown::Artist do
  before(:each) do
    @options = {
      name: 'Little Brother',
      url: 'http://www.bandsintown.com/LittleBrother',
      mbid: 'b929c0c9-5de0-4d87-8eb9-365ad1725629'
    }
    @artist = Bandsintown::Artist.new(@options)
  end

  describe 'attributes' do
    it 'should have an attr_accessor for @name' do
      expect(@artist).to respond_to(:name)
      expect(@artist).to respond_to(:name=)
    end
    it 'should have an attr_accessor for @bandsintown_url' do
      expect(@artist).to respond_to(:bandsintown_url)
      expect(@artist).to respond_to(:bandsintown_url=)
    end
    it 'should have an attr_accessor for @mbid' do
      expect(@artist).to respond_to(:mbid)
      expect(@artist).to respond_to(:mbid=)
    end
    it 'should have an attr_accessor for @upcoming_events_count' do
      expect(@artist).to respond_to(:upcoming_events_count)
      expect(@artist).to respond_to(:upcoming_events_count=)
    end
  end

  describe '.initialize(options = {})' do
    it 'should set the Artist name from options' do
      expect(@artist.name).to eq(@options[:name])
    end
    it 'should set the Artist bandsintown_url from options' do
      expect(@artist.bandsintown_url).to eq(@options[:url])
    end
    it 'should set the Artist mbid from options' do
      expect(@artist.mbid).to eq(@options[:mbid])
    end

    describe 'generating a url (initialized without an option for :url)' do
      it 'should strip spaces' do
        name = 'The Beatles '
        expect(Bandsintown::Artist.new(name: name).bandsintown_url).to eq('http://www.bandsintown.com/TheBeatles')
      end
      it "should convert '&' -> 'And'" do
        name = 'Meg & Dia'
        expect(Bandsintown::Artist.new(name: name).bandsintown_url).to eq('http://www.bandsintown.com/MegAndDia')
      end
      it "should convert '+' -> 'Plus'" do
        name = '+44'
        expect(Bandsintown::Artist.new(name: name).bandsintown_url).to eq('http://www.bandsintown.com/Plus44')
      end
      it 'should camelcase seperate words' do
        name = 'meg & dia'
        expect(Bandsintown::Artist.new(name: name).bandsintown_url).to eq('http://www.bandsintown.com/MegAndDia')
      end
      it 'should not cgi escape url' do
        name = '$up'
        expect(Bandsintown::Artist.new(name: name).bandsintown_url).to eq('http://www.bandsintown.com/$up')
      end
      it 'should uri escape accented characters' do
        name = 'sigur rós'
        expect(Bandsintown::Artist.new(name: name).bandsintown_url).to eq('http://www.bandsintown.com/SigurR%C3%B3s')
      end
      it 'should not alter the case of single word names' do
        name = 'AWOL'
        expect(Bandsintown::Artist.new(name: name).bandsintown_url).to eq('http://www.bandsintown.com/AWOL')
      end
      it 'should allow dots' do
        name = 'M.I.A'
        expect(Bandsintown::Artist.new(name: name).bandsintown_url).to eq('http://www.bandsintown.com/M.I.A')
      end
      it 'should allow exclamations' do
        name = 'against me!'
        expect(Bandsintown::Artist.new(name: name).bandsintown_url).to eq('http://www.bandsintown.com/AgainstMe!')
      end
      it 'should not modify @options[:name]' do
        name = 'this is how i think'
        Bandsintown::Artist.new(name: name)
        expect(name).to eq('this is how i think')
      end
      it "should cgi escape '/' so it will be double encoded" do
        name = 'AC/DC'
        escaped_name = URI.escape(name.gsub('/', CGI.escape('/')))
        expect(Bandsintown::Artist.new(name: name).bandsintown_url).to eq("http://www.bandsintown.com/#{escaped_name}")
      end
      it "should cgi escape '?' so it will be double encoded" do
        name = 'Does it offend you, yeah?'
        escaped_name = URI.escape("DoesItOffendYou,Yeah#{CGI.escape('?')}")
        expect(Bandsintown::Artist.new(name: name).bandsintown_url).to eq("http://www.bandsintown.com/#{escaped_name}")
      end
      it 'should use @mbid only if @name is nil' do
        expect(Bandsintown::Artist.new(name: 'name', mbid: 'mbid').bandsintown_url).to eq('http://www.bandsintown.com/name')
        expect(Bandsintown::Artist.new(mbid: '1234').bandsintown_url).to eq('http://www.bandsintown.com/mbid_1234')
      end
    end
  end

  describe '.resource_path' do
    it 'should return the API resource path for artists' do
      expect(Bandsintown::Artist.resource_path).to eq('artists')
    end
  end

  describe '#events' do
    before(:each) do
      @artist = Bandsintown::Artist.new(name: 'Little Brother')
    end
    it "should request and parse a call to the BIT artist events API method and the artist's api name" do
      expect(@artist).to receive(:api_name).and_return('Little%20Brother')
      expect(Bandsintown::Artist).to receive(:request_and_parse).with(:get, 'Little%20Brother/events').and_return([])
      @artist.events
    end
    it 'should return an Array of Bandsintown::Event objects built from the response' do
      event_1 = double(Bandsintown::Event)
      event_2 = double(Bandsintown::Event)
      results = ['event 1', 'event 2']
      allow(Bandsintown::Artist).to receive(:request_and_parse).and_return(results)
      expect(Bandsintown::Event).to receive(:build_from_json).with('event 1').ordered.and_return(event_1)
      expect(Bandsintown::Event).to receive(:build_from_json).with('event 2').ordered.and_return(event_2)
      expect(@artist.events).to eq([event_1, event_2])
    end
    it 'should be cached' do
      @artist.events = 'events'
      expect(Bandsintown::Artist).not_to receive(:request_and_parse)
      expect(@artist.events).to eq('events')
    end
  end

  describe '#api_name' do
    it 'should URI escape @name' do
      expect(@artist.api_name).to eq(URI.escape(@artist.name))
    end
    it 'should CGI escape / and ? characters before URI escaping the whole name' do
      expect(Bandsintown::Artist.new(name: 'AC/DC').api_name).to eq(URI.escape(CGI.escape('AC/DC')))
      expect(Bandsintown::Artist.new(name: '?uestlove').api_name).to eq(URI.escape(CGI.escape('?uestlove')))
    end
    it "should use 'mbid_<@mbid>' only if @name is nil" do
      expect(Bandsintown::Artist.new(name: 'name', mbid: 'mbid').api_name).to eq('name')
      expect(Bandsintown::Artist.new(mbid: '1234').api_name).to eq('mbid_1234')
    end
  end

  describe '.get(options = {})' do
    before(:each) do
      @options = { name: 'Pete Rock' }
      @artist = Bandsintown::Artist.new(@options)
      allow(Bandsintown::Artist).to receive(:request_and_parse).and_return('json')
      allow(Bandsintown::Artist).to receive(:build_from_json).and_return('built artist')
    end
    it 'should initialize a Bandsintown::Artist from options' do
      expect(Bandsintown::Artist).to receive(:new).with(@options).and_return(@artist)
      Bandsintown::Artist.get(@options)
    end
    it 'should request and parse a call to the BIT artists - get API method using api_name' do
      expect(Bandsintown::Artist).to receive(:request_and_parse).with(:get, @artist.api_name).and_return('json')
      Bandsintown::Artist.get(@options)
    end
    it 'should return the result of Bandsintown::Artist.build_from_json with the response data' do
      expect(Bandsintown::Artist).to receive(:build_from_json).with('json').and_return('built artist')
      expect(Bandsintown::Artist.get(@options)).to eq('built artist')
    end
  end

  describe '.build_from_json(json_hash)' do
    before(:each) do
      @name = 'Pete Rock'
      @bandsintown_url = 'http://www.bandsintown.com/PeteRock'
      @mbid = '39a973f2-0785-4ef6-90d9-551378864f89'
      @upcoming_events_count = 7
      @json_hash = {
        'name' => @name,
        'url' => @bandsintown_url,
        'mbid' => @mbid,
        'upcoming_events_count' => @upcoming_events_count
      }
      @artist = Bandsintown::Artist.build_from_json(@json_hash)
    end
    it 'should return an instance of Bandsintown::Artist' do
      expect(@artist).to be_instance_of(Bandsintown::Artist)
    end
    it 'should set the name' do
      expect(@artist.name).to eq(@name)
    end
    it 'should set the mbid' do
      expect(@artist.mbid).to eq(@mbid)
    end
    it 'should set the bandsintown_url' do
      expect(@artist.bandsintown_url).to eq(@bandsintown_url)
    end
    it 'should set the upcoming events count' do
      expect(@artist.upcoming_events_count).to eq(@upcoming_events_count)
    end
  end

  describe '#on_tour?' do
    it 'should return true if @upcoming_events_count is greater than 0' do
      @artist.upcoming_events_count = 1
      expect(@artist).to be_on_tour
    end
    it 'should return false if @upcoming_events_count is 0' do
      @artist.upcoming_events_count = 0
      expect(@artist).not_to be_on_tour
    end
    it 'should raise an error if both @upcoming_events_count and @events are nil' do
      expect { @artist.on_tour? }.to raise_error
    end
    describe 'when @upcoming_events_count is nil' do
      it 'should return true if @events is not empty (.events only returns upcoming events)' do
        @artist.events = [double(Bandsintown::Event)]
        expect(@artist).to be_on_tour
      end
      it 'should return false if @events is empty' do
        @artist.events = []
        expect(@artist).not_to be_on_tour
      end
    end
  end

  describe '#cancel_event(event_id)' do
    before(:each) do
      @event_id = 12_345
      @artist = Bandsintown::Artist.new(name: 'Little Brother')
      @response = { 'message' => 'Event successfully cancelled (pending approval)' }
      allow(Bandsintown::Artist).to receive(:request_and_parse).and_return(@response)
    end
    it "should request and parse a call to the BIT artists - cancel event API method using the artist's api_name and the given event_id" do
      expect(Bandsintown::Artist).to receive(:request_and_parse).with(:post, "#{@artist.api_name}/events/#{@event_id}/cancel").and_return(@response)
      @artist.cancel_event(@event_id)
    end
    it 'should return the response message if an event was successfully cancelled' do
      expect(@artist.cancel_event(@event_id)).to eq(@response['message'])
    end
  end

  describe '.create(options = {})' do
    before(:each) do
      @options = {
        name: 'A New Artist',
        myspace_url: 'http://www.myspace.com/a_new_artist',
        mbid: 'abcd1234-abcd-1234-5678-abcd12345678',
        website: 'http://www.a-new-artist.com'
      }
      allow(Bandsintown::Artist).to receive(:request_and_parse).and_return('json')
      allow(Bandsintown::Artist).to receive(:build_from_json).and_return('built artist')
    end
    it 'should request and parse a call to the BIT artists - create API method using the supplied artist data' do
      expected_params = { artist: @options }
      expect(Bandsintown::Artist).to receive(:request_and_parse).with(:post, '', expected_params).and_return('json')
      Bandsintown::Artist.create(@options)
    end
    it 'should return the result of Bandsintown::Artist.build_from_json with the response data' do
      expect(Bandsintown::Artist).to receive(:build_from_json).with('json').and_return('built artist')
      expect(Bandsintown::Artist.create(@options)).to eq('built artist')
    end
  end
end
