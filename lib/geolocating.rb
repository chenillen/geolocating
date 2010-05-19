require 'net/http'
require 'net/geoip'
require 'open-uri'
require 'erb'        
require 'crack/json' # for just json

module Geolocating
  class TooManyQueriesError < StandardError; end
  
  # Contains a range of geocoders:
  # 
  # ### "regular" address geocoders 
  # * Google Geocoder V3 - both geocoding and reverse geo coding requires an API key.
  # * MindMax - IP geocoding
  # * IP Geocoder - geocodes an IP address using hostip.info's web service. 
  # See the README.
  
  module Geocoders
    @@google_api = 'REPLACE_WITH_YOUR_GOOGLE_KEY'
    @@mindmax_api = 'REPLACE_WITH_YOUR_MINDMAX_KEY'
    @@request_timeout = nil
    
    def self.__define_accessors
      class_variables.each do |v| 
        sym = v.to_s.delete("@").to_sym
        unless self.respond_to? sym
          module_eval <<-EOS, __FILE__, __LINE__
            def self.#{sym}
              value = if defined?(#{sym.to_s.upcase})
                #{sym.to_s.upcase}
              else
                @@#{sym}
              end
              if value.is_a?(Hash)
                value = (self.domain.nil? ? nil : value[self.domain]) || value.values.first
              end
              value
            end
          
            def self.#{sym}=(obj)
              @@#{sym} = obj
            end
          EOS
        end
      end
    end
    
     __define_accessors
    
    # Error which is thrown in the event a geocoding error occurs.
    class GeocodeError < StandardError; end

    # -------------------------------------------------------------------------------------------
    # Geocoder Base class -- every geocoder should inherit from this
    # -------------------------------------------------------------------------------------------    
    
    # The Geocoder base class which defines the interface to be used by all
    # other geocoders.
    
    class Geocoder
      # Main method which calls the do_geocode template method which subclasses
      # are responsible for implementing.  Returns a populated GeoLoc or an
      # empty one with a failed success code.
      def self.geocode(address, options = {}) 
        res = do_geocode(address, options)
        return res.nil? ? GeoLoc.new : res
      end  
      # Main method which calls the do_reverse_geocode template method which subclasses
      # are responsible for implementing.  Returns a populated GeoLoc or an
      # empty one with a failed success code.
      def self.reverse_geocode(latlng)
        res = do_reverse_geocode(latlng)
        return res.success? ? res : GeoLoc.new        
      end
      
      # Call the geocoder service using the timeout if configured.
      def self.call_geocoder_service(url)
        Timeout::timeout(Geokit::Geocoders::request_timeout) { return self.do_get(url) } if Geokit::Geocoders::request_timeout        
        return self.do_get(url)
      rescue TimeoutError
        return nil  
      end

      # Not all geocoders can do reverse geocoding. So, unless the subclass explicitly overrides this method,
      # a call to reverse_geocode will return an empty GeoLoc. If you happen to be using MultiGeocoder,
      # this will cause it to failover to the next geocoder, which will hopefully be one which supports reverse geocoding.
      def self.do_reverse_geocode(latlng)
        return GeoLoc.new
      end

      protected

      def self.logger() 
        Geokit::Geocoders::logger
      end
      
      private
      
      # Wraps the geocoder call around a proxy if necessary.
      def self.do_get(url) 
        uri = URI.parse(url)
        req = Net::HTTP::Get.new(url)
        req.basic_auth(uri.user, uri.password) if uri.userinfo
        res = Net::HTTP::Proxy(GeoKit::Geocoders::proxy_addr,
                GeoKit::Geocoders::proxy_port,
                GeoKit::Geocoders::proxy_user,
                GeoKit::Geocoders::proxy_pass).start(uri.host, uri.port) { |http| http.get(uri.path + "?" + uri.query) }
        return res
      end
      
      # Adds subclass' geocode method making it conveniently available through 
      # the base class.
      def self.inherited(clazz)
        class_name = clazz.name.split('::').last
        src = <<-END_SRC
          def self.#{Geokit::Inflector.underscore(class_name)}(address, options = {})
            #{class_name}.geocode(address, options)
          end
        END_SRC
        class_eval(src)
      end
    end
    
    class GoogleGeocoder < Geocoder
      GEOCODE_BASE_URL = 'http://maps.google.com/maps/api/geocode/json'
      
      def initialize(args)
          
      end
      
      def locating_by_address(address, sensor)
        url = GEOCODE_BASE_URL + '?' + 'address=' + ERB::Util.url_encode(address) + '&' + 'language=zh-CN' + '&' + "sensor=#{sensor}"
        parse_res = Crack::JSON.parse(Net::HTTP.get URI.parse(url))
        case parse_res['status']
        # Google Map Status Codes
        # "OK" indicates that no errors occurred; the address was successfully parsed and at least one geocode was returned.
        # "ZERO_RESULTS" indicates that the geocode was successful but returned no results. This may occur if the geocode was passed a non-existent address or a latlng in a remote location.
        # "OVER_QUERY_LIMIT" indicates that you are over your quota.
        # "REQUEST_DENIED" indicates that your request was denied, generally because of lack of a sensor parameter.
        # "INVALID_REQUEST" generally indicates that the query (address or latlng) is missing.  
        when 'OK'
          res = parse_res['results']
          res.each do |key|
            puts key['formatted_address']
            puts key['geometry']['location']['lat']
            puts key['geometry']['location']['lng']
            puts key['geometry']['location_type']
            puts key['geometry']['viewport']
          end
        when 'ZERO_RESULTS'
          puts 'No venue founded!'
        else # 'OVER_QUERY_LIMIT', 'REQUEST_DENIED', 'INVALID_REQUEST'
          puts 'Please contact the Web adminstrator'       
        end
      end

      def locating_by_latlng(latlng, sensor)
        latlng = self.venue_lat + ',' self.venue_long
        url = GEOCODE_BASE_URL + '?' + 'latlng=' + ERB::Util.url_encode(latlng) + '&' + 'language=zh-CN' + '&' + "sensor=#{sensor}" 
      end
    end 
    
    class MmaxGeocoder < Geocoder
      GEOCODE_BASE_URL = 'REPLACE BY MINDMA'
      def initialize(args)
        
      end
      
      
    end
  end
end