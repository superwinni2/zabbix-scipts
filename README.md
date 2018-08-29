If you want to monitor your AVM DECT devices you can use this script.

I don't know which Zabbix Version is minimum required.

I've testet it with Version 3.4.

I'm a native german speaker, but I'm looking forward to translate the script that it is working with german and english words.
___
Requirements:
curl need to be installed
___
Preparations:

Go to your Fritzbox and create a new user (default in my script is user "zabbix" with password "123456")

Register your DECT device on the FritzBox write down the "AIN" Number of your device. We need that later.
___
Instructions:

Copy script to "External Scripts" directory of your Zabbix server. (Defaults to "/usr/lib/zabbix/externalscripts" you can look in your zabbix_server.conf)

Open script and change variables "Fritzbox", "username" and "password"

Fritzbox=Your FritzBox Address

Username=Your Username to logon into your Fritzbox

Passwort=Password for Username

.

Create a new host:

Name Host like what you like to (e.g. "Television")

Cause external scripts can only be executed by zabbix server, the ip is 127.0.0.1 or localhost.

On "Macros" create {$AIN} and type in your Number of your device (without spacebars)
 
.
 
Create new Item:

Name it like what you want to measure... (e.g. "Power consumption")

Type: External check

Key: ["{$AIN}","Leistung"]

Type of information: Numeric (float)

Units: W (for Watts)

Update interval: 2m (it doesn't measure any faster)

On Preprocession add a custom multiplier of 0.001.

Save the Item.
Now it should measure the power consumption.

___
Possible Values:

Liste - List of all AIN devices. Sperator is comma (,)

Zustand - 0 = switch is off, 1 = switch is on, "inval" if unknown


Status - 0 = not connected, 1 = connected (via DECT) if connection is lost it need some minutes to fall back to 0

Leistung - Power Consumption in mW. "inval" if unknown

Energie - Energy in Wh. "inval" if unknown

Name - Name of switch. Can be configured on FritzBox Interface.

Infos - List infos of all SmartHome devices in XML Format

Temperatur - Temperature of switch in 0.1°C. Examples: 200 -> 20°C | 255 -> 25,5°C

Solltemperatur - Configured "should be temperature" for thermostat in 0.5°C. 16-56 -> 8-28 °C (19 -> 9,5 °C)

Komforttemperatur - Configured "comfort temperature" for thermostat in 0.5°C. 16-56 -> 8-28 (19 -> 9,5 °C)

Spartemperatur - Configured "saving temperature" for thermostat in 0.5°C. 16-56 -> 8-28 °C (19 -> 9,5 °C)
___
Debugging:

Execute script manually with third paramater "1"

Example:

/usr/lib/zabbix/externalscripts/dect.sh 123456789101 Leistung 1
