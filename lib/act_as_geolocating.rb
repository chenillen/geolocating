# coding: utf-8

module Geolocating
  module ActAsGeolocating
    # Mix below class methods into ActiveRecord.
    def self.included(base) # :nodoc:
      base.extend ClassMethods
    end

    module ClassMethods
      def acts_as_geolocating
        
      end
      
      
    end
    
    module SingletonMethods
      
    end
  end
end