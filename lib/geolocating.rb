require 'net/http'
require 'net/geoip'
require 'open-uri'
require 'erb'        
require 'crack/json' # for just json

module Geolocating
  class TooManyQueriesError < StandardError; end
  module Geocoders
    @@google = 'REPLACE_WITH_YOUR_GOOGLE_KEY'
    @@mindmax
    
    # Error which is thrown in the event a geocoding error occurs.
    class GeocodeError < StandardError; end

    # -------------------------------------------------------------------------------------------
    # Geocoder Base class -- every geocoder should inherit from this
    # -------------------------------------------------------------------------------------------    
    
    # The Geocoder base class which defines the interface to be used by all
    # other geocoders.
    
    class Geocoder
      
    end
    
    class GoogleGeocoder < Geocoder
      GEOCODE_BASE_URL = 'http://maps.google.com/maps/api/geocode/json'
      
      def initialize(args)
          
      end
      
      def find_by_address
        
      end
                                       

      def geocode(address, sensor)
        # address = self.addr + ' ' + self.location.city
        url = GEOCODE_BASE_URL + '?' + 'address=' + ERB::Util.url_encode(address) + '&' + 'language=zh-CN' + '&' + 'region=US' + '&' + "sensor=#{sensor}"
        parse_res = Crack::JSON.parse(Net::HTTP.get URI.parse(url))
        if parse_res['status'] == 'OK' 
          res = parse_res['results']
          res.each do |key|
            puts key['formatted_address']
            puts key['geometry']['location']['lat']
            puts key['geometry']['location']['lng']
            puts key['geometry']['location_type']
            puts key['geometry']['viewport']
          end  
        else
          raise "Shit!"
        end  
      end

      # geocode('东城区王府井大街99号世纪大厦A座609室', false)
    end 
    
    class MmaxGeocoder < Geocoder
      GEOCODE_BASE_URL = 'REPLACE BY MINDMA'
      def initialize(args)
        
      end
      
      
    end
  end
end