siriproxy-isy99i
================

About
-----

Siriproxy-isy99i is a [SiriProxy] (https://github.com/plamoni/SiriProxy) plugin that allows you to control home automation devices using the [Universal Devices ISY-99i Series] (http://www.universal-devices.com/residential-2/isy-99i) controller through Apple's Siri interface on the iPhone 4s.

Utilizing the REST interface of the ISY-99i, this plugin matches certain voice commands and sends the appropriate command via http to the controller.  See below for specific usage.

I would also like to point out that I am not a programmer, and haven't coded in Ruby before, so go easy on me.  I've done some php coding (more like hacking) and that is about it.  I gave myself a crash course in Ruby once I learned of this project, and that is it.  Google has been a very close friend over the past week or so...

I am fully aware of the fact that the code could be cleaner, done differently, done better, or whatever.  Feel free to point out mistakes/corrections, offer constructive criticism, etc... This is a work in progress and I'm counting on the community to help make it better.

Installation
------------

First and foremost, [SiriProxy] (https://github.com/plamoni/SiriProxy) must be installed and working.  Do not attempt to do anything with this plugin until you have installed SiriProxy and have verified that it is working correctly.  The author provides very detailed, step-by-step written instructions, as well as video, on how to do this.  

Once SiriProxy is up and running, you'll want to add the siriproxy-isy99i plugin.  This will have to be done manually, as it is necessary to add your specific devices and their addresses to a configuration file (devices.rb).  This process is a bit more complicated that some other plugins, but I will walk you through the steps I used.  

It may also be helpful to look at this [video by jbaybayjbaybay] (http://www.youtube.com/watch?v=A48SGUt_7lw) as it's the one I used to figure this process out.  The video includes info on creating a new plugin and editing the files, which can be helpful when it comes to experimenting with your own plugins, but it won't be necessary in order to just install this plugin.  So, I'll skip those particular instructions below.

1.  Download the repository as a [zip file] (https://github.com/hoopty3/siriproxy-isy99i/zipball/master).
2.  Extract the full directory (i.e. hoopty3-siriproxy-isy99i-######) to `~/.rvm/gems/ruby-1.9.3-p0@SiriProxy/gems/siriproxy-0.3.0/plugins` and rename it siriproxy-isy99i. You will need to go to View and select 'Show Hidden Files' in order to see .rvm directory.
3.  Navigate to the `siriproxy-isy99i/lib` directory and open devices.rb for editing.  Gedit works just fine.
4.  Here you will need to enter your specific device info, such as what you will call them and their addresses.  This file is populated with examples and should be pretty self explanatory.  
5.  If a device is dimmable, set the @dimmable variable to 1, otherwise it is not necessary or should be set to some number other than 1.  You can control devices or scenes, but you cannot currently get the status of a scene (that's on the to do list).
6.  Copy the siriproxy-99i directory to `home/SiriProxy/plugins` directory
7.  Open up siriproxy-isy99i/config-info.yml and copy all the settings listed there.
8.  Navigate to `~/.siriproxy` and open config.yml for editing.
9.  Paste the settings copied from config-info.yml into config.yml making sure to keep format and line spacing same as the examples.  
10. Set the host, username, and password fields for your system's configuration.  Don't forget to save the file when you're done.
11. Open a terminal and navigate to ~/SiriProxy
12. Type `siriproxy bundle` <enter>
13. Type `bundle install` <enter>
14. Type `rvmsudo siriproxy server` <enter> followed by your password.
15. SiriProxy with ISY99i control is now ready for use.

Usage
-----

**Turn on (device name)**
- Will check the status of that device and determine its state.  
- If it's On and it's a dimmer, Siri will give you the status and ask if you want to adjust the brightness settings.  
- If it's Off and it's a dimmer, Siri will ask what percent you would like to turn it On to.  It it's not dimmable, it will just turn On.
- If it's On, Siri will alert you that it is already On.
- Otherwise, if Siri misunderstands you or that device isn't configured in devices.rb, you will be alerted that the device isn't programmed for control.

**Turn off (device name)**
- Will check the status of that device and determine its state.  
- If it's On, Siri will shut it Off.  
- If it's Off, Siri will alert you that it is already Off.
- Otherwise, if Siri misunderstands you or that device isn't configured in devices.rb, you will be alerted that the device isn't programmed for control.

**Get status of (device name)**
- Siri will request the status of the device from the ISY-99i and report it back to you.
- Otherwise, if Siri misunderstands you or that device isn't configured in devices.rb, you will be alerted that the device isn't programmed for control.

**Dim/turn up/turn down/set dimmer on/set level on (device name)**

**NOTE -- This particular function hasn't been behaving very well for me.  Siri has a hard time understanding the word 'dim'.  At least when I speak it.  If anyone has any ideas on how to improve this, let me know!**

- If device is dimmable, Siri will ask what you would like to set the On percentage to and then issue the command to change that setting.
- Otherwise, if Siri misunderstands you or that device isn't configured in devices.rb, you will be alerted that the device isn't programmed for control.



**NOTE -- Thermostat functions are currently limited to one thermostat.  I know there are many of you that have multiple thermostats in your setup, and it shouldn't be too hard to incorporate them into the code, but I only have one so that is what I coded.  I have it on my to do list...**

**What is the temperature/inside inside/temperature temperature/in here?**
- Gets current temperature from your thermostat and reports it to you.

**What is the status/thermostat thermostat/status?**
- Will retrieve and report the status of the following: current temp, cooling setpoing, heating setpoint, and mode.

**Set cooling/cool setpoint/cooling setpoint to (##)**
- Will set the cooling setpoint of your thermostat to whatever 2 digit value you tell it to.

**Set heat/heating/heat setpoint/heating setpoint to (##)**
- Will set the heating setpoint of your thermostat to whatever 2 digit value you tell it to.

Above are the main arguments that have been coded so far for use with the ISY-99i controller.  I have programmed in some specific phrases and instructions for my use.  These can be found in the siriproxy-isy99i.rb file.  Feel free to edit these and make it your own.  I only ask that you share any funny or neat applications that you come up with.

Example:  
- Me:  Merry Christmas Siri!
- Siri: Merry Christmas, Jesse!  Do you want me to put the tree lights on?
- Me: Yes/sure/yep/ok/whatever
- Siri turns on the tree lights.
- Or...
- Me: No thanks
- Siri: Scrooge!

**NOTE -- If/when you make changes to either devices.rb or siriproxy-isy99i.rb, you must copy it to the other plugin directory.  Remember, you put a copy in** `~/.rvm/gems/ruby-1.9.3-p0@SiriProxy/gems/siriproxy-0.3.0/plugins` **AND** `home/SiriProxy/plugins`**.  They both have to match!  Then follow steps 11 - 15 of the installation procedure to load up your changes and start the server again.**

To Do List
----------

- Continue to refine the speech patterns for better recognition
- Organize/streamline the code
- Enable better scene controls (i.e. code in the REST commands for scene status)
- Enable multiple thermostat control
- Perhaps develop code for self awareness of devices/addresses (would require major overhaul and be completely different from current methods)
- The sky's the limit!  Accepting any and all inputs...

Acknowledgements
----------------

I really gotta thank [plamoni] (https://github.com/plamoni) for developing the SiriProxy and putting it out there for the rest of us tinkerers to play with.  It has been a lot of fun exploring how to use it in new and different ways.

I also have to thank all the other plugin developers for sharing their code as well.  I couldn't have put this thing together without the examples that they put forward.

Thanks guys!

Licensing
---------

Re-use of my code is fine under a Creative Commons 3.0 [Non-commercial, Attribution, Share-Alike](http://creativecommons.org/licenses/by-nc-sa/3.0/) license. In short, this means that you can use my code, modify it, do anything you want. Just don't sell it and make sure to give me a shout-out. Also, you must license your derivatives under a compatible license (sorry, no closed-source derivatives). If you would like to purchase a more permissive license (for a closed-source and/or commercial license), please contact me directly. See the Creative Commons site for more information.


Disclaimer
----------

I'm not affiliated with Apple in any way. They don't endorse this application. They own all the rights to Siri (and all associated trademarks). 

This software is provided as-is with no warranty whatsoever. Use at your own risk!  I am not responsible for any damages/corruption which may occure to your system.  (It's not gonna happen, but I gotta say it...)

Apple could do things to block this kind of behavior if they want. Also, if you cause problems (by sending lots of trash to the Guzzoni servers or anything), I fully support Apple's right to ban your UDID (making your phone unable to use Siri). They can, and I wouldn't blame them if they do.

I'm a huge fan of Apple and the work that they do. Siri is a very cool feature and I'm pretty excited to explore it and add functionality. Please refrain from using this software for anything malicious.
