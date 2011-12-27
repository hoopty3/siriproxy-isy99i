require 'uri'
require 'cora'
require 'httparty'
require 'rubygems'
require 'devices'
require 'siri_objects'


class SiriProxy::Plugin::Isy99i < SiriProxy::Plugin
  attr_accessor :password
  attr_accessor :username
  attr_accessor :host
  
  def initialize(config)  
    self.password = config["password"]
    self.username = config["username"]
    self.host = config["host"]
    @auth = {:username => "#{self.username}", :password => "#{self.password}"}
  end

  class Rest
    include HTTParty
    format :xml
  end


  listen_for(/merry christmas/i) {merry_christmas}
  listen_for(/scrooge|turn off tree|turn off christmas lights/i) {scrooge}
  listen_for(/ready to go|leave/i) {open_small_garage_door}
  listen_for(/pulling (in|up|in the driveway)/i) {open_small_garage_door}
  listen_for(/close the garage door/i) {close_small_garage_door}
  listen_for (/cooling.*([0-9]{2})|cool setpoint.*([0-9]{2})|cooling setpoint.*([0-9]{2})/i) { |cooling_temp| set_cool_temp(cooling_temp) }
  listen_for (/heat.*([0-9]{2})|heating.*([0-9]{2})|heat setpoint.*([0-9]{2})|heating setpoint.*([0-9]{2})/i) { |heating_temp| set_heat_temp(heating_temp) }


  listen_for (/turn on (.*)/i) do |device|
    deviceName = URI.unescape(device.strip)
    @dimmable = 0 #sets default as non-dimmable - must be set to 1 in devices file otherwise
    deviceAddress = deviceCrossReference(deviceName)
    puts "deviceAddress = #{deviceAddress}"
    puts "deviceName = #{deviceName}"
    if deviceAddress != 0
      check_status = Rest.get("#{self.host}/rest/status/#{deviceAddress}", :basic_auth => @auth).inspect
      status = check_status.gsub(/^.*tted"=>"/, "")
      status = status.gsub(/", "uom.*$/, "")
      status_dimmer = status.to_i
        if status_dimmer > 0
          say "Status of #{deviceName} is already On, and it's set to #{status_dimmer}%"
          response = ask "Would you like to adjust the brightness settings?"
            if (response =~ /yes|sure|yep|yeah|whatever|why not|ok|I guess/i)
              dim_percent = ask "OK. What percentage would you like me to set #{deviceName} to?"
              dim_percent_adj = dim_percent.to_i * 2.55 #converts percent to 0-255 setpoint
              dim_percent_adj = dim_percent_adj.to_i
              say "I am setting #{deviceName} to #{dim_percent.to_i}%."
              Rest.get("#{self.host}/rest/nodes/#{deviceAddress}/cmd/DON/#{dim_percent_adj}", :basic_auth => @auth)
            else say "OK.  Suit yourself"
            end
        elsif status == "Off"
          if @dimmable == 1
            dim_percent = ask "This device is dimmable.  What would you like to set the level to?"
            dim_percent_adj = dim_percent.to_i * 2.55 #converts percent to 0-255 setpoint
            dim_percent_adj = dim_percent_adj.to_i
            say "I am setting #{deviceName} to #{dim_percent.to_i}%."
            Rest.get("#{self.host}/rest/nodes/#{deviceAddress}/cmd/DON/#{dim_percent_adj}", :basic_auth => @auth)
          else say "I am turning on #{deviceName} now."
            Rest.get("#{self.host}/rest/nodes/#{deviceAddress}/cmd/DON", :basic_auth => @auth)
          end
        elsif status == "On"
          if @dimmable == 1
            response = ask "This device is already On, and it's set to 100%. Do you want to change the level?"
              if (response =~ /yes|sure|yep|yeah|whatever|why not|ok|I guess/i)
                dim_percent = ask "OK. What percentage would you like me to set #{deviceName} to?"
                dim_percent_adj = dim_percent.to_i * 2.55 #converts percent to 0-255 setpoint
                dim_percent_adj = dim_percent_adj.to_i
                say "I am setting #{deviceName} to #{dim_percent.to_i}%."
                Rest.get("#{self.host}/rest/nodes/#{deviceAddress}/cmd/DON/#{dim_percent_adj}", :basic_auth => @auth)
              else say "OK.  Suit yourself"
              end
          else say "But master, that device is already On"
          end
        else status = "error"
             say "I'm sorry, but there seems to be an error and I am currently unable to control #{deviceName}"
        end
    else say "I'm sorry, but I am not programmed to control #{deviceName}."
    end
    request_completed
  end

  listen_for (/turn off (.*)/i) do |device|
    deviceName = URI.unescape(device.strip)
    deviceAddress = deviceCrossReference(deviceName)
      if deviceAddress != 0
        check_status = Rest.get("#{self.host}/rest/status/#{deviceAddress}", :basic_auth => @auth).inspect
        status = check_status.gsub(/^.*tted"=>"/, "")
        status = status.gsub(/", "uom.*$/, "")
          if status == "On" || (status.to_i >= 1 && status.to_i <= 100)
            say "I am now turning off #{deviceName}."
            Rest.get("#{self.host}/rest/nodes/#{deviceAddress}/cmd/DOF", :basic_auth => @auth)
          elsif status == "Off"
            say "But master, that device is already off"
          else status = "error"
            say "I'm sorry, but there seems to be an error and I am currently unable to control #{deviceName}"
          end
        else say "I'm sorry, but I am not programmed to control #{deviceName}."
          #say "#{anything_else}?"
      end
    request_completed
  end


  listen_for (/get status of (.*)/i) do |device|
    deviceName = URI.unescape(device.strip)
    @dimmable = 0 #sets default as non-dimmable - has to be set to 1 in devices file otherwise
    deviceAddress = deviceCrossReference(deviceName)
      if deviceAddress != 0
        check_status = Rest.get("#{self.host}/rest/status/#{deviceAddress}", :basic_auth => @auth).inspect
        status = check_status.gsub(/^.*tted"=>"/, "")
        status = status.gsub(/", "uom.*$/, "")
        status_dimmer = status.to_i
          if status_dimmer > 0
            say "Status of #{deviceName} is On, and it's set to #{status_dimmer}%"
          elsif status == "On" || "Off"
            if @dimmable == 1 && status == "On"
              say "Status of #{deviceName} is On at 100%"
            else say "Status of #{deviceName} is #{status}"
            end
          else status = "error"
            say "I'm sorry, but there seems to be an error and I am unable to return status for #{deviceName}"
          end
      else say "I'm sorry, but I am not programmed to control #{deviceName}."
      end
    request_completed
  end


  listen_for (/(dim|damn|jim|jimmer|turn down|turn up|turnup|set dimmer on|set level on|set the level on) (.*)/i) do |keywords, device|
    deviceName = URI.unescape(device.strip)
    @dimmable = 0
    deviceAddress = deviceCrossReference(deviceName)
    if deviceAddress != 0
      check_status = Rest.get("#{self.host}/rest/status/#{deviceAddress}", :basic_auth => @auth).inspect
      status = check_status.gsub(/^.*tted"=>"/, "")
      status = status.gsub(/", "uom.*$/, "")
      status_dimmer = status.to_i
        if @dimmable == 1
          dim_percent = ask "What would you like to set the level to?"
          dim_percent_adj = dim_percent.to_i * 2.55 #converts percent to 0-255 setpoint
          dim_percent_adj = dim_percent_adj.to_i
          say "I am setting #{deviceName} to #{dim_percent.to_i}%."
          Rest.get("#{self.host}/rest/nodes/#{deviceAddress}/cmd/DON/#{dim_percent_adj}", :basic_auth => @auth)
        elsif @dimmable == 0
          say "I'm sorry, but #{deviceName} is not dimmable."
        else status = "error"
             say "I'm sorry, but there seems to be an error and I am currently unable to control #{deviceName}"
        end
    else say "I'm sorry, but I am not programmed to control #{deviceName}."
    end
    request_completed
  end


  listen_for (/temperature.*inside|inside.*temperature|temperature.*in here/i) do 
    deviceName = "thermostat"
    deviceAddress = deviceCrossReference(deviceName)
      if deviceAddress != 0
        #say "Checking the inside temperature."
        check_status = Rest.get("#{self.host}/rest/status/#{deviceAddress}", :basic_auth => @auth).inspect
        indoor_temp = check_status.gsub(/^.*"ST\D+\d+\D+/, "")
        indoor_temp = indoor_temp.gsub(/\D\d\d", "uom.*$/, "")
        say "The current temperature in your house is #{indoor_temp} degrees."
      end
    request_completed 
  end


  listen_for (/thermostat.*status|status.*thermostat/i) do 
    deviceName = "thermostat"
    deviceAddress = deviceCrossReference(deviceName)
    #say "Checking the status of the thermostat."
    check_status = Rest.get("#{self.host}/rest/status/#{deviceAddress}", :basic_auth => @auth).inspect
    indoor_temp = check_status.gsub(/^.*"ST\D+\d+\D+/, "")
    indoor_temp = indoor_temp.gsub(/\D\d\d", "uom.*$/, "")
    say "The current temperature in your house is #{indoor_temp} degrees." 
    clispc = check_status.gsub(/^.*"CLISPC\D+\d+\", "\w+"=>"/, "")
    clispc = clispc.gsub(/\D\d\d", "uom.*$/, "")
    say "The cooling setpoint is #{clispc} degrees"
    clisph = check_status.gsub(/^.*"CLISPH\D+\d+\", "\w+"=>"/, "")
    clisph = clisph.gsub(/\D\d\d", "uom.*$/, "")
    say "The heating setpoint is #{clisph} degrees"
    climd = check_status.gsub(/^.*"CLIMD\D+\d+\", "\w+"=>"/, "")
    climd = climd.gsub(/", "uom.*$/, "")
    say "The mode is currently set to #{climd}"
    request_completed 
  end


  def set_cool_temp(cooling_temp)
    deviceName = "thermostat"
    deviceAddress = deviceCrossReference(deviceName)
    cooling_temp = cooling_temp.to_i * 2   #necessary as thermostat input must be doubled
    say "One moment while I set the cooling setpoint to #{cooling_temp} degrees."
    Rest.get("#{self.host}/rest/nodes/#{deviceAddress}/set/CLISPC/#{cooling_temp}", :basic_auth => @auth).inspect
    request_completed
  end


  def set_heat_temp(heating_temp)
    deviceName = "thermostat"
    deviceAddress = deviceCrossReference(deviceName)
    heating_temp = heating_temp.to_i * 2   #necessary as thermostat input must be doubled
    say "One moment while I set the heating setpoint to #{heating_temp} degrees."
    Rest.get("#{self.host}/rest/nodes/#{deviceAddress}/set/CLISPH/#{heating_temp}", :basic_auth => @auth).inspect
    request_completed
  end


  def anything_else
    response = ask "Is there anything else you would like me to do?"
      if (response =~ /yes|sure|yep|yeah|whatever|why not|ok|I guess/i)
        say "OK, but I'm still working on that part of my programming."
      else say "Good.  Because I can't do that yet."
      end
    request_completed
  end


  def open_small_garage_door
    say "OK.  I'll open the garage door for you"
    Rest.get("#{self.host}/rest/nodes/46642/cmd/DON", :basic_auth => @auth)
    request_completed 
  end


  def close_small_garage_door
    say "Garage door is now closing."
    Rest.get("#{self.host}/rest/nodes/46642/cmd/DOF", :basic_auth => @auth)
    request_completed 
  end


  def merry_christmas
    response = ask "Merry Christmas master! Do you want me to put the tree lights on?"
      if (response =~ /yes|sure|yep|yeah|whatever|why not|ok|I guess/i)
        Rest.get("#{self.host}/rest/nodes/24409/cmd/DON", :basic_auth => @auth)
      else say "Scrooge!"
      end
    request_completed 
  end

  def scrooge
    say "Scrooge!"
    Rest.get("#{self.host}/rest/nodes/24409/cmd/DOF", :basic_auth => @auth)
    request_completed 
  end
  
end
