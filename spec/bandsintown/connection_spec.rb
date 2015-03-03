require File.dirname(__FILE__) + '/../spec_helper.rb'

describe Bandsintown::Connection do
  before(:each) do
    Bandsintown.app_id = 'YOUR_APP_ID'
    @base_url = 'http://api.bandsintown.com'
  end

  describe '.initialize(base_url)' do
    before(:each) do
      @connection = Bandsintown::Connection.new(@base_url)
    end
    it 'should set the base_url for the Connection' do
      expect(@connection.base_url).to eq(@base_url)
    end
  end

  describe '.get(resource_path, method_path, params = {})' do
    before(:each) do
      @connection = Bandsintown::Connection.new(@base_url)
      allow(RestClient).to receive(:get).and_return('response')
      @api_resource = 'events'
      @api_method = 'search'
    end
    it 'should make a get request to the url constructed with resource path, method path, and encoded params' do
      params = { artists: ['Little Brother', 'Joe Scudda'], location: 'Boston, MA', radius: 10 }
      request_url = 'http://api.bandsintown.com/events/search?app_id=YOUR_APP_ID&artists%5B%5D=Little+Brother&artists%5B%5D=Joe+Scudda&format=json&location=Boston%2C+MA&radius=10'
      expect(@connection).to receive(:encode).with(params).and_return('app_id=YOUR_APP_ID&artists%5B%5D=Little+Brother&artists%5B%5D=Joe+Scudda&format=json&location=Boston%2C+MA&radius=10')
      expect(RestClient).to receive(:get).with(request_url).and_return('response')
      expect(@connection.get(@api_resource, @api_method, params)).to eq('response')
    end

    it 'should return the API error message instead of raising an error if there was a problem with the request (404 response)' do
      error = RestClient::ResourceNotFound.new; error.response = 'error message'
      allow(RestClient).to receive(:get).and_raise(error)
      expect { @connection.get('', '', {}) }.not_to raise_error
      expect(@connection.get('', '', {})).to eq('error message')
    end

    it 'should return the correct URL format when method_path is blank (no slashes)' do
      expected_url = 'http://api.bandsintown.com/events?app_id=YOUR_APP_ID&format=json'
      expect(RestClient).to receive(:get).with(expected_url).and_return('response')
      @connection.get('events', '', {})
    end
  end

  describe '.post(resource_path, method_path, body = {})' do
    before(:each) do
      @connection = Bandsintown::Connection.new(@base_url)
      allow(RestClient).to receive(:post).and_return('response')
      @api_resource = 'events'
      @api_method = ''
      @body_params = {
        event: {
          artists: [{ name: 'Little Brother' }],
          datetime: '2010-06-01T19:30:00',
          venue: { id: 123 }
        }
      }
    end
    it 'should make a post request to the url constructed with resource path, method path, default encoded params, body converted to json, and application/json request headers' do
      expected_url = 'http://api.bandsintown.com/events?app_id=YOUR_APP_ID&format=json'
      expected_body = @body_params.to_json
      expected_headers = { content_type: :json, accept: :json }
      expect(@connection).to receive(:encode).with({}).and_return('app_id=YOUR_APP_ID&format=json')
      expect(RestClient).to receive(:post).with(expected_url, expected_body, expected_headers).and_return('response')
      expect(@connection.post(@api_resource, @api_method, @body_params)).to eq('response')
    end

    it 'should return the API error message instead of raising an error if there was a problem with the request (404 response)' do
      error = RestClient::ResourceNotFound.new; error.response = 'error message'
      allow(RestClient).to receive(:post).and_raise(error)
      expect { @connection.post(@api_resource, @api_method, @body_params) }.not_to raise_error
      expect(@connection.post(@api_resource, @api_method, @body_params)).to eq('error message')
    end
  end

  describe '.encode(params={})' do
    before(:each) do
      @connection = Bandsintown::Connection.new(@base_url)
    end
    it 'should return a query param string including :app_id and :format => json without the user having to specify them' do
      expect(@connection.encode({})).to eq("app_id=#{Bandsintown.app_id}&format=json")
    end
    it 'should convert params[:start_date] and params[:end_date] to a single params[:date] parameter' do
      params = { start_date: '2009-01-01', end_date: '2009-02-01' }
      expect(@connection.encode(params)).to eq("app_id=#{Bandsintown.app_id}&date=2009-01-01%2C2009-02-01&format=json")
    end
    it 'should allow :date to be a Time object' do
      params = { date: Time.now.beginning_of_day }
      expect(@connection.encode(params)).to eq("app_id=#{Bandsintown.app_id}&date=#{Time.now.strftime('%Y-%m-%d')}&format=json")
    end
    it 'should allow :date to be a Date object' do
      params = { date: Date.today }
      expect(@connection.encode(params)).to eq("app_id=#{Bandsintown.app_id}&date=#{Date.today}&format=json")
    end
    it 'should allow :date to be a String object' do
      params = { date: '2009-01-01' }
      expect(@connection.encode(params)).to eq("app_id=#{Bandsintown.app_id}&date=2009-01-01&format=json")
    end
    it 'should allow :start_date and :end_date to be Time objects' do
      params = { start_date: 1.week.ago, end_date: 1.week.from_now }
      expect(@connection.encode(params)).to eq("app_id=#{Bandsintown.app_id}&date=#{1.week.ago.strftime('%Y-%m-%d')}%2C#{1.week.from_now.strftime('%Y-%m-%d')}&format=json")
    end
    it 'should allow :start_date and :end_date to be Date objects' do
      params = { start_date: 1.week.ago.to_date, end_date: 1.week.from_now.to_date }
      expect(@connection.encode(params)).to eq("app_id=#{Bandsintown.app_id}&date=#{1.week.ago.strftime('%Y-%m-%d')}%2C#{1.week.from_now.strftime('%Y-%m-%d')}&format=json")
    end
    it 'should allow :start_date and :end_date to be String objects' do
      params = { start_date: '2009-01-01', end_date: '2009-02-01' }
      expect(@connection.encode(params)).to eq("app_id=#{Bandsintown.app_id}&date=2009-01-01%2C2009-02-01&format=json")
    end
  end
end
