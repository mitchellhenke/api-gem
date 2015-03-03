module Bandsintown
  class Base
    attr_accessor :bandsintown_url

    def self.request(http_method, api_method, args = {})
      case http_method
      when :get  then connection.get(resource_path, api_method, args)
      when :post then connection.post(resource_path, api_method, args)
      else fail ArgumentError, 'only :get and :post requests are supported'
      end
    end

    def self.connection
      @connection ||= Bandsintown::Connection.new('http://api.bandsintown.com')
    end

    def self.parse(response)
      json = JSON.parse(response)
      check_for_errors(json)
      json
    end

    def self.check_for_errors(json)
      if json.is_a?(Hash) && json.key?('errors')
        fail Bandsintown::APIError.new(json['errors'].join(', '))
      end
    end

    def self.request_and_parse(http_method, api_method, args = {})
      parse(request(http_method, api_method, args))
    end

    def to_hash
      hash = {}
      instance_variables.each do |ivar|
        value = instance_variable_get(ivar)
        next if value.blank?
        hash[:"#{ivar.to_s.gsub('@', '')}"] = value
      end
      hash
    end
  end
end
