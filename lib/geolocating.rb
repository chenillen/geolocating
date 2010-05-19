require 'net/http'
require 'net/geoip'
require 'yaml'

module Geolocating
  class TooManyQueriesError < StandardError; end
  module Geocoders
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
      def initialize(args)
          
      end
      
      
    end 
    
    class MmaxGeocoder < Geocoder
      def initialize(args)
        
      end
      
      
    end
  end
end