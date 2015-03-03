require File.dirname(__FILE__) + '/../spec_helper.rb'

describe Bandsintown::Venue do
  describe 'attributes' do
    before(:each) do
      @venue = Bandsintown::Venue.new(123)
    end
    it 'should have an accessor for @name' do
      expect(@venue).to respond_to(:name)
      expect(@venue).to respond_to(:name=)
    end
    it 'should have an accessor for @bandsintown_id' do
      expect(@venue).to respond_to(:bandsintown_id)
      expect(@venue).to respond_to(:bandsintown_id=)
    end
    it 'should have an accessor for @bandsintown_url' do
      expect(@venue).to respond_to(:bandsintown_url)
      expect(@venue).to respond_to(:bandsintown_url=)
    end
    it 'should have an accessor for @address' do
      expect(@venue).to respond_to(:address)
      expect(@venue).to respond_to(:address=)
    end
    it 'should have an accessor for @city' do
      expect(@venue).to respond_to(:city)
      expect(@venue).to respond_to(:city=)
    end
    it 'should have an accessor for @region' do
      expect(@venue).to respond_to(:region)
      expect(@venue).to respond_to(:region=)
    end
    it 'should have an accessor for @postalcode' do
      expect(@venue).to respond_to(:postalcode)
      expect(@venue).to respond_to(:postalcode=)
    end
    it 'should have an accessor for @country' do
      expect(@venue).to respond_to(:country)
      expect(@venue).to respond_to(:country=)
    end
    it 'should have an accessor for @latitude' do
      expect(@venue).to respond_to(:latitude)
      expect(@venue).to respond_to(:latitude=)
    end
    it 'should have an accessor for @longitude' do
      expect(@venue).to respond_to(:longitude)
      expect(@venue).to respond_to(:longitude=)
    end
    it 'should have an accessor for @events' do
      expect(@venue).to respond_to(:events)
      expect(@venue).to respond_to(:events=)
    end
  end

  describe '.initialize(bandsintown_id)' do
    it 'should set @bandsintown_id to bandsintown_id' do
      expect(Bandsintown::Venue.new(123).bandsintown_id).to eq(123)
    end
  end

  describe '.build_from_json(options = {})' do
    before(:each) do
      @name = 'Paradise Rock Club'
      @url = 'http://www.bandsintown.com/venue/327987'
      @id = 327_987
      @region = 'MA'
      @city = 'Boston'
      @country = 'United States'
      @latitude = 42.37
      @longitude = 71.03

      @venue = Bandsintown::Venue.build_from_json('name' => @name,
                                                  'url' => @url,
                                                  'id' => @id,
                                                  'region' => @region,
                                                  'city' => @city,
                                                  'country' => @country,
                                                  'latitude' => @latitude,
                                                  'longitude' => @longitude)
    end
    it 'should return a Bandsintown::Venue instance' do
      expect(@venue).to be_instance_of(Bandsintown::Venue)
    end
    it 'should set the name' do
      expect(@venue.name).to eq(@name)
    end
    it 'should set the bandsintown_url' do
      expect(@venue.bandsintown_url).to eq(@url)
    end
    it 'should set the bandsintown_id' do
      expect(@venue.bandsintown_id).to eq(@id)
    end
    it 'should set the region' do
      expect(@venue.region).to eq(@region)
    end
    it 'should set the city' do
      expect(@venue.city).to eq(@city)
    end
    it 'should set the country' do
      expect(@venue.country).to eq(@country)
    end
    it 'should set the longitude' do
      expect(@venue.longitude).to eq(@longitude)
    end
    it 'should set the latitude' do
      expect(@venue.latitude).to eq(@latitude)
    end
  end

  describe '.resource_path' do
    it 'should return the path for Venue requests' do
      expect(Bandsintown::Venue.resource_path).to eq('venues')
    end
  end

  describe '.search(options={})' do
    before(:each) do
      @args = { location: 'Boston, MA', query: 'House of Blues' }
    end
    it 'should request and parse a call to the BIT venues search api method' do
      expect(Bandsintown::Venue).to receive(:request_and_parse).with(:get, 'search', @args).and_return([])
      Bandsintown::Venue.search(@args)
    end
    it 'should return an Array of Bandsintown::Venue objects built from the response' do
      results = [
        { 'id' => '123', 'name' => 'house of blues' },
        { 'id' => '456', 'name' => 'house of blues boston' }
      ]
      allow(Bandsintown::Venue).to receive(:request_and_parse).and_return(results)
      venues = Bandsintown::Venue.search(@args)
      expect(venues).to be_instance_of(Array)

      expect(venues.first).to be_instance_of(Bandsintown::Venue)
      expect(venues.first.bandsintown_id).to eq('123')
      expect(venues.first.name).to eq('house of blues')

      expect(venues.last).to be_instance_of(Bandsintown::Venue)
      expect(venues.last.bandsintown_id).to eq('456')
      expect(venues.last.name).to eq('house of blues boston')
    end
  end

  describe '#events' do
    before(:each) do
      @bandsintown_id = 123
      @venue = Bandsintown::Venue.new(@bandsintown_id)
    end
    it 'should request and parse a call to the BIT venues - events API method with @bandsintown_id' do
      expect(Bandsintown::Venue).to receive(:request_and_parse).with(:get, "#{@bandsintown_id}/events").and_return([])
      @venue.events
    end
    it 'should return an Array of Bandsintown::Event objects built from the response' do
      event_1 = double(Bandsintown::Event)
      event_2 = double(Bandsintown::Event)
      results = ['event 1', 'event 2']
      allow(Bandsintown::Venue).to receive(:request_and_parse).and_return(results)
      expect(Bandsintown::Event).to receive(:build_from_json).with('event 1').ordered.and_return(event_1)
      expect(Bandsintown::Event).to receive(:build_from_json).with('event 2').ordered.and_return(event_2)
      expect(@venue.events).to eq([event_1, event_2])
    end
    it 'should be memoized' do
      @venue.events = 'events'
      expect(Bandsintown::Venue).not_to receive(:request_and_parse)
      expect(@venue.events).to eq('events')
    end
  end
end
