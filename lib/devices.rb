require 'cora'


  def deviceCrossReference(deviceName)


    if(deviceName.match(/christmas tree|christmas lights|tree/i))
    return 24409 #can be set to either a scene (#####) or a device (##%20##%20##%20#)
                 #if set to a device, the %20 must be used in place of the space and
                 #you must use quotation marks around it ex. return "12%2034%2056%207"


    elsif(deviceName.match(/kitchen lights|kitchen light/i))
    return 53453


    elsif(deviceName.match(/night scene|night/i))
    return 12393


    elsif(deviceName.match(/test|text|test switch|text switch/i))
    return "1B%2041%2082%201"  #device
    #return 27377               #scene


    elsif(deviceName.match(/undercounter lights|under counter lights|under cabinet lights|cabinet lights|counter lights/i))
    return 28826

    elsif(deviceName.match(/thermostat|temperature/i))
    return "14%2013%2064%201"

    else 
    return 0
    end
    return deviceName
  end


    #elsif(deviceName.match(/undercounter lights/i) || deviceName.match(/under counter lights/i) || deviceName.match(/under cabinet lights/i) || deviceName.match(/cabinet lights/i) || deviceName.match(/counter lights/i))
    #return 28826

