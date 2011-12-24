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

  class Cmd
    include HTTParty
    format :xml
  end

  #listen_for(/test/i) { test }
  listen_for(/merry christmas/i) {merry_christmas}
  listen_for(/scrooge|turn off tree|turn off christmas lights/i) {scrooge}
  listen_for(/ready to go|leave/i) {open_small_garage_door}
  listen_for(/pulling (in|up|in the driveway)/i) {open_small_garage_door}
  listen_for(/close the garage door/i) {close_small_garage_door}
  listen_for (/cooling.*([0-9]{2})|cool setpoint.*([0-9]{2})|cooling setpoint.*([0-9]{2})/i) { |cooling_temp| set_cool_temp(cooling_temp) }
  listen_for (/heat.*([0-9]{2})|heat setpoint.*([0-9]{2})|heating setpoint.*([0-9]{2})/i) { |heating_temp| set_heat_temp(heating_temp) }



  listen_for (/(siri) turn on (.*)/i) do |keyword, query|
    deviceName = URI.unescape(query.strip)
    deviceAddress = deviceCrossReference(deviceName)

    if deviceAddress != 0
       check_status = Cmd.get("#{self.host}/rest/status/#{deviceAddress}", :basic_auth => @auth).inspect
       status = check_status.gsub(/^.*tted"=>"/, "")
       status = status.gsub(/", "uom.*$/, "")
       #say "Status of device is #{status}"
      if status != "On" && status !="Off" #necessary for controlling scenes, as no status is available
         status = "no_status"
         #say "If - Status of device is #{status}"
      end
    end

    if (deviceAddress != 0 && status == "Off") || status == "no_status"
       #say "Status of device is #{status}"
       say "I am turning on #{deviceName} now."
       command = Cmd.get("#{self.host}/rest/nodes/#{deviceAddress}/cmd/DON", :basic_auth => @auth)
    elsif deviceAddress != 0 && status == "On"
          #say "Status of device is #{status}"
          say "But master, that device is already on."
    else say "I'm sorry, I am not programmed to control #{deviceName}."
         #say "Status of device is #{status}"
         #say "#{anything_else}"
    end
    request_completed
  end

  listen_for (/(siri) turn off (.*)/i) do |keyword, query|
    deviceName = URI.unescape(query.strip)
    deviceAddress = deviceCrossReference(deviceName)

    if deviceAddress != 0
       check_status = Cmd.get("#{self.host}/rest/status/#{deviceAddress}", :basic_auth => @auth).inspect
       status = check_status.gsub(/^.*tted"=>"/, "")
       status = status.gsub(/", "uom.*$/, "")
      if status != "On" && status != "Off"
         status = "no_status"
      end
    end

    if (deviceAddress != 0 && status == "On") || status == "no_status"
       say "I am now turning off #{deviceName}."
       cmd = HTTParty.get("#{self.host}/rest/nodes/#{deviceAddress}/cmd/DOF", :basic_auth => @auth)
    elsif deviceAddress != 0 && status == "Off"
          say "But master, that device is already off"
    else say "I'm sorry, I am not programmed to control #{deviceName}."
         #say "#{anything_else}"
    end
    request_completed
  end

  listen_for (/(siri) get status of (.*)/i) do |keyword, query|
    deviceName = URI.unescape(query.strip)
    deviceAddress = deviceCrossReference(deviceName)

    if deviceAddress != 0
       check_status = Cmd.get("#{self.host}/rest/status/#{deviceAddress}", :basic_auth => @auth).inspect
       status = check_status.gsub(/^.*tted"=>"/, "")
       status = status.gsub(/", "uom.*$/, "")
       say "Status of #{deviceName} is #{status}"
      if status != "On" && status != "Off"
         status = "no_status"
      end
    end
    request_completed
  end

  listen_for (/temperature.*inside|inside.*temperature|temperature.*in here/i) do |keyword, query|
    #deviceName = URI.unescape(query.strip)
    deviceName = "thermostat"
    deviceAddress = deviceCrossReference(deviceName)

    if deviceAddress != 0
       #say "Checking the inside temperature."
       check_status = Cmd.get("#{self.host}/rest/status/#{deviceAddress}", :basic_auth => @auth).inspect
       indoor_temp = check_status.gsub(/^.*"ST\D+\d+\D+/, "")
       indoor_temp = indoor_temp.gsub(/\D\d\d", "uom.*$/, "")
       say "The current temperature in your house is #{indoor_temp} degrees."
    end
    request_completed 
  end

  listen_for (/thermostat.*status|status.*thermostat/i) do |keyword, query|
    deviceName = "thermostat"
    deviceAddress = deviceCrossReference(deviceName)

       #say "Checking the status of the thermostat."
       check_status = Cmd.get("#{self.host}/rest/status/#{deviceAddress}", :basic_auth => @auth).inspect

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
    say "One moment while I set the cooling setpoint to #{cooling_temp} degrees."
    deviceName = "thermostat"
    deviceAddress = deviceCrossReference(deviceName)
    cooling_temp = cooling_temp.to_i * 2   #necessary as thermostat input must be doubled
    command = Cmd.get("#{self.host}/rest/nodes/#{deviceAddress}/set/CLISPC/#{cooling_temp}", :basic_auth => @auth).inspect
    request_completed
  end

  def set_heat_temp(heating_temp)
    say "One moment while I set the heating setpoint to #{heating_temp} degrees."
    deviceName = "thermostat"
    deviceAddress = deviceCrossReference(deviceName)
    heating_temp = heating_temp.to_i * 2   #necessary as thermostat input must be doubled
    command = Cmd.get("#{self.host}/rest/nodes/#{deviceAddress}/set/CLISPH/#{heating_temp}", :basic_auth => @auth).inspect
    request_completed
  end

  def anything_else
    response = ask "Is there anything else you would like me to do?"
    if(response =~ /yes/i)
       say "OK, but I'm still working on that part of my programming."
    else
       say "Good.  Because I can't do that yet."
    end
       request_completed
  end


    def test
          cmd = HTTParty.get("#{self.host}/rest/nodes/1B%2041%2082%201/cmd/DON", :basic_auth => @auth)
          say "Test complete!"
          sleep(5)
          cmd = HTTParty.get("#{self.host}/rest/nodes/1B%2041%2082%201/cmd/DOF", :basic_auth => @auth)
          request_completed 
    end

    def open_small_garage_door
          say "OK.  I'll open the garage door for you"
          cmd = HTTParty.get("#{self.host}/rest/nodes/46642/cmd/DON", :basic_auth => @auth)
          request_completed 
    end

    def close_small_garage_door
          say "Garage door is now closing."
          cmd = HTTParty.get("#{self.host}/rest/nodes/46642/cmd/DOF", :basic_auth => @auth)
          request_completed 
    end

    def merry_christmas
          response = ask "Merry Christmas! Do you want me to put the tree lights on?"
          if  (response =~ /yes|yeah|sure|why not|ok|whatever/i)
              cmd = HTTParty.get("#{self.host}/rest/nodes/24409/cmd/DON", :basic_auth => @auth)
          else
	      say "Scrooge!"
          end
          request_completed 
    end

    def scrooge
          say "Scrooge!"
          cmd = HTTParty.get("#{self.host}/rest/nodes/24409/cmd/DOF", :basic_auth => @auth)
          request_completed 
    end

#listen_for (/turn on/i) do
    #response = ask "What do you want me to turn on?" 

    #if(response =~ /kitchen light/i) 
       #whatever = HTTParty.get("http://192.168.1.138/rest/nodes/1B%2041%2082%201/cmd/DON", :basic_auth => @auth)

    #else
      #say "Sorry, but I am only programmed to turn on the Kitchen Light"
    #end
    
    #request_completed 
  #end




  
end
