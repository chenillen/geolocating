module Geolocating
  module ClassMethods
    
  end
  
  module InstanceMethods
    
  end
  
  def self.included(receiver)
    receiver.extend         ClassMethods
    receiver.send :include, InstanceMethods
  end
  
  module ActAsMapping
    class GoogleGeoCoder
      
    end
    
    class IPGeoCoder
      
    end
    
    class AddrGeo < GoogleGeo
      def initialize(args)
        
      end
      
      
    end
    
    class LatlngGeo < GoogleGeo
      def initialize(args)
        
      end
      
      
    end
    
    class IPGeo < IPGeo
      def initialize(args)
        
      end
      
      
    end
    
  end
end