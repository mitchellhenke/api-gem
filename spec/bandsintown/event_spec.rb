require File.dirname(__FILE__) + '/../spec_helper.rb'

describe Bandsintown::Event do
  it 'should include the Bandsintown::Event::CreationHelpers module' do
    expect(Bandsintown::Event.included_modules).to include(Bandsintown::Event::CreationHelpers)
  end

  describe '.resource_path' do
    it 'should return the relative path to Event requests' do
      expect(Bandsintown::Event.resource_path).to eq('events')
    end
  end

  describe '.search(options = {})' do
    before(:each) do
      @args = { location: 'Boston, MA', date: '2009-01-01' }
    end
    it 'should request and parse a call to the BIT events search api method' do
      expect(Bandsintown::Event).to receive(:request_and_parse).with(:get, 'search', @args).and_return([])
      Bandsintown::Event.search(@args)
    end
    it 'should return an Array of Bandsintown::Event objects built from the response' do
      event_1 = double(Bandsintown::Event)
      event_2 = double(Bandsintown::Event)
      results = ['event 1', 'event 2']
      allow(Bandsintown::Event).to receive(:request_and_parse).and_return(results)
      expect(Bandsintown::Event).to receive(:build_from_json).with('event 1').ordered.and_return(event_1)
      expect(Bandsintown::Event).to receive(:build_from_json).with('event 2').ordered.and_return(event_2)
      expect(Bandsintown::Event.search(@args)).to eq([event_1, event_2])
    end
  end

  describe '.recommended(options = {})' do
    before(:each) do
      @args = { location: 'Boston, MA', date: '2009-01-01' }
    end
    it 'should request and parse a call to the BIT recommended events api method' do
      expect(Bandsintown::Event).to receive(:request_and_parse).with(:get, 'recommended', @args).and_return([])
      Bandsintown::Event.recommended(@args)
    end
    it 'should return an Array of Bandsintown::Event objects built from the response' do
      event_1 = double(Bandsintown::Event)
      event_2 = double(Bandsintown::Event)
      results = ['event 1', 'event 2']
      allow(Bandsintown::Event).to receive(:request_and_parse).and_return(results)
      expect(Bandsintown::Event).to receive(:build_from_json).with('event 1').ordered.and_return(event_1)
      expect(Bandsintown::Event).to receive(:build_from_json).with('event 2').ordered.and_return(event_2)
      expect(Bandsintown::Event.recommended(@args)).to eq([event_1, event_2])
    end
  end

  describe '.daily' do
    it 'should request and parse a call to the BIT daily events api method' do
      expect(Bandsintown::Event).to receive(:request_and_parse).with(:get, 'daily').and_return([])
      Bandsintown::Event.daily
    end
    it 'should return an array of Bandsintown::Events built from the response' do
      event = double(Bandsintown::Event)
      allow(Bandsintown::Event).to receive(:request_and_parse).and_return(['event json'])
      expect(Bandsintown::Event).to receive(:build_from_json).with('event json').and_return(event)
      expect(Bandsintown::Event.daily).to eq([event])
    end
  end

  describe '.on_sale_soon(options = {})' do
    before(:each) do
      @args = { location: 'Boston, MA', radius: 50, date: '2010-03-02' }
    end
    it 'should request and parse a call to the BIT on sale soon api method' do
      expect(Bandsintown::Event).to receive(:request_and_parse).with(:get, 'on_sale_soon', @args).and_return([])
      Bandsintown::Event.on_sale_soon(@args)
    end
    it 'should return an array of Bandsintown::Events built from the response' do
      event = double(Bandsintown::Event)
      allow(Bandsintown::Event).to receive(:request_and_parse).and_return(['event json'])
      expect(Bandsintown::Event).to receive(:build_from_json).with('event json').and_return(event)
      expect(Bandsintown::Event.daily).to eq([event])
    end
  end

  describe '.build_from_json(json_hash)' do
    before(:each) do
      @event_id   = 745_089
      @event_url  = 'http://www.bandsintown.com/event/745095'
      @datetime   = '2008-09-30T19:30:00'
      @ticket_url = 'http://www.bandsintown.com/event/745095/buy_tickets'

      @artist_1 = { 'name' => 'Little Brother', 'url' => 'http://www.bandsintown.com/LittleBrother', 'mbid' => 'b929c0c9-5de0-4d87-8eb9-365ad1725629' }
      @artist_2 = { 'name' => 'Joe Scudda', 'url' => 'http://www.bandsintown.com/JoeScudda', 'mbid' => nil } # sorry Joe its just an example

      @venue_hash = {
        'id' => 327_987,
        'url' => 'http://www.bandsintown.com/venue/327987',
        'region' => 'MA',
        'city' => 'Boston',
        'name' => 'Paradise Rock Club',
        'country' => 'United States',
        'latitude' => 42.37,
        'longitude' => 71.03
      }

      @event_hash = {
        'id' => @event_id,
        'url' => @event_url,
        'datetime' => @datetime,
        'ticket_url' => @ticket_url,
        'artists' => [@artist_1, @artist_2],
        'venue' => @venue_hash,
        'status' => 'new',
        'ticket_status' => 'available',
        'on_sale_datetime' => '2008-09-01T19:30:00'
      }

      @built_event = Bandsintown::Event.build_from_json(@event_hash)
    end
    it 'should return a built Event' do
      expect(@built_event).to be_instance_of(Bandsintown::Event)
    end
    it 'should set the Event id' do
      expect(@built_event.bandsintown_id).to eq(@event_id)
    end
    it 'should set the Event url' do
      expect(@built_event.bandsintown_url).to eq(@event_url)
    end
    it 'should set the Event datetime' do
      expect(@built_event.datetime).to eq(Time.parse(@datetime))
    end
    it 'should set the Event ticket url' do
      expect(@built_event.ticket_url).to eq(@ticket_url)
    end
    it 'should set the Event status' do
      expect(@built_event.status).to eq('new')
    end
    it 'should set the Event ticket_status' do
      expect(@built_event.ticket_status).to eq('available')
    end
    it 'should set the Event on_sale_datetime' do
      expect(@built_event.on_sale_datetime).to eq(Time.parse(@event_hash['on_sale_datetime']))
    end
    it 'should set the Event on_sale_datetime to nil if not given' do
      @event_hash['on_sale_datetime'] = nil
      expect(Bandsintown::Event.build_from_json(@event_hash).on_sale_datetime).to be_nil
    end
    it "should set the Event's Venue" do
      venue = @built_event.venue
      expect(venue).to be_instance_of(Bandsintown::Venue)
      expect(venue.bandsintown_id).to eq(327_987)
      expect(venue.bandsintown_url).to eq('http://www.bandsintown.com/venue/327987')
      expect(venue.region).to eq('MA')
      expect(venue.city).to eq('Boston')
      expect(venue.name).to eq('Paradise Rock Club')
      expect(venue.country).to eq('United States')
      expect(venue.latitude).to eq(42.37)
      expect(venue.longitude).to eq(71.03)
    end
    it "should set the Event's Artists" do
      artists = @built_event.artists
      expect(artists).to be_instance_of(Array)
      expect(artists.size).to eq(2)

      expect(artists.first).to be_instance_of(Bandsintown::Artist)
      expect(artists.first.name).to eq('Little Brother')
      expect(artists.first.bandsintown_url).to eq('http://www.bandsintown.com/LittleBrother')
      expect(artists.first.mbid).to eq('b929c0c9-5de0-4d87-8eb9-365ad1725629')

      expect(artists.last).to be_instance_of(Bandsintown::Artist)
      expect(artists.last.name).to eq('Joe Scudda')
      expect(artists.last.bandsintown_url).to eq('http://www.bandsintown.com/JoeScudda')
      expect(artists.last.mbid).to be_nil
    end
  end

  describe '#tickets_available?' do
    it "should return true if @ticket_status is 'available'" do
      event = Bandsintown::Event.new
      event.ticket_status = 'available'
      expect(event.tickets_available?).to be_truthy
    end
    it "should return false if @ticket_status is not 'available'" do
      event = Bandsintown::Event.new
      event.ticket_status = 'unavailable'
      expect(event.tickets_available?).to be_falsey
    end
  end

  describe '.create(options = {})' do
    before(:each) do
      @options = { artists: [], venue: {}, datetime: '' }
      @response = { 'message' => 'Event successfully submitted (pending approval)' }
      allow(Bandsintown::Event).to receive(:request_and_parse).and_return(@response)
    end
    it 'should request and parse a call to the BIT events - create API mehod' do
      expect(Bandsintown::Event).to receive(:request_and_parse).with(:post, '', anything).and_return(@response)
      Bandsintown::Event.create(@options)
    end
    it 'should return the response message if an event was successfully submitted using a non-trusted app_id' do
      expect(Bandsintown::Event).not_to receive(:build_from_json)
      expect(Bandsintown::Event.create(@options)).to eq(@response['message'])
    end
    it 'should return a Bandsintown::Event build from the response if an event was sucessfully submitted using a trusted app_id' do
      allow(Bandsintown::Event).to receive(:request_and_parse).and_return('event' => 'data')
      event = double(Bandsintown::Event)
      expect(Bandsintown::Event).to receive(:build_from_json).with('data').and_return(event)
      expect(Bandsintown::Event.create(@options)).to eq(event)
    end
    describe 'event options' do
      before(:each) do
        allow(Bandsintown::Event).to receive(:parse_artists)
        allow(Bandsintown::Event).to receive(:parse_datetime)
        allow(Bandsintown::Event).to receive(:parse_venue)
      end

      it 'should parse the artists using parse_artists' do
        @options = { artists: %w(Evidence Alchemist) }
        expect(Bandsintown::Event).to receive(:parse_artists).with(@options[:artists]).and_return('parsed')
        expected_event_params = { artists: 'parsed' }
        expect(Bandsintown::Event).to receive(:request_and_parse).with(:post, '', event: hash_including(expected_event_params))
      end

      it 'should parse the datetime using parse_datetime' do
        @options = { datetime: '2010-06-01T20:30:00' }
        expect(Bandsintown::Event).to receive(:parse_datetime).with(@options[:datetime]).and_return('parsed')
        expected_event_params = { datetime: 'parsed' }
        expect(Bandsintown::Event).to receive(:request_and_parse).with(:post, '', event: hash_including(expected_event_params))
      end

      it 'should parse the on_sale_datetime using parse_datetime' do
        @options = { on_sale_datetime: '2010-06-01T20:30:00' }
        expect(Bandsintown::Event).to receive(:parse_datetime).with(@options[:on_sale_datetime]).and_return('parsed')
        expected_event_params = { on_sale_datetime: 'parsed' }
        expect(Bandsintown::Event).to receive(:request_and_parse).with(:post, '', event: hash_including(expected_event_params))
      end

      it 'should parse the venue using parse_venue' do
        @options = { venue: 'data' }
        expect(Bandsintown::Event).to receive(:parse_venue).with('data').and_return('venue')
        expected_event_params = { venue: 'venue' }
        expect(Bandsintown::Event).to receive(:request_and_parse).with(:post, '', event: hash_including(expected_event_params))
      end

      after(:each) do
        Bandsintown::Event.create(@options)
      end
    end
  end

  describe '#cancel' do
    before(:each) do
      @event = Bandsintown::Event.new
      @event.bandsintown_id = 12_345
      @response = { 'message' => 'Event successfully cancelled (pending approval)' }
      allow(Bandsintown::Event).to receive(:request_and_parse).and_return(@response)
    end
    it 'should raise an error if the event does not have a bandsintown_id' do
      @event.bandsintown_id = nil
      expect { @event.cancel }.to raise_error(StandardError, 'event cancellation requires a bandsintown_id')
    end
    it "should request and parse a call to the BIT events - cancel API method using the event's bandsintown_id" do
      expect(Bandsintown::Event).to receive(:request_and_parse).with(:post, "#{@event.bandsintown_id}/cancel").and_return(@response)
      @event.cancel
    end
    it 'should return the response message if an event was successfully cancelled' do
      expect(@event.cancel).to eq(@response['message'])
    end
  end
end
