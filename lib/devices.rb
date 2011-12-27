require 'cora'


  def deviceCrossReference(deviceName)


    if (deviceName.match(/christmas tree|christmas lights|tree/i))

      @dimmable = 0 #must be set to 1 in order to recognize dimmable devices
                    #otherwise, not necessary or set to 0.

    return "19%207D%20DB%201" #can be set to either a scene (#####) or a device (##%20##%20##%20#)
    #return 24409             #if set to a device, the %20 must be used in place of the space and
                              #you must use quotation marks around it ex. return "12%2034%2056%207"
                              #NOTE: If your device address has a zero in it, it must be ommitted from 
                              #from the settings in this file i.e. 1A.0B.9F = 1A%20B%209F%201


    elsif (deviceName.match(/kitchen lights|kitchen light/i))
    return "19%2027%2073%201"


    elsif (deviceName.match(/night scene|night/i))
    return 12393


    elsif (deviceName.match(/dining room|dining room light/i))
      @dimmable = 1
    return "1A%2028%20BB%201"


    elsif (deviceName.match(/test|text|test switch|text switch/i))
      @dimmable = 1
    return "1A%2020%20BA%201"   #device = test dimmer
    #return "1B%2041%2082%201"  #device = test relay
    #return 27377               #scene for both


    elsif (deviceName.match(/undercounter lights|under counter lights|under cabinet lights|cabinet lights|counter lights/i))
    return 28826


    elsif (deviceName.match(/thermostat|temperature/i))
    return "14%2013%2064%201"


    elsif (deviceName.match(/garage door light/i))
      @dimmable = 1
    return "1A%2024%2061%201"


    elsif (deviceName.match(/.*entry light|.*entry/i))
      @dimmable = 1
    return "1A%20B%209F%201"


    else 
    return 0
    end
    return deviceName
  end


    #elsif(deviceName.match(/undercounter lights/i) || deviceName.match(/under counter lights/i) || deviceName.match(/under cabinet lights/i) || deviceName.match(/cabinet lights/i) || deviceName.match(/counter lights/i))
    #return 28826

