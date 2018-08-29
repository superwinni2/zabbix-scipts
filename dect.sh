#!/bin/bash

# # Variablen
# Umgebung
DatenDir="/tmp"
lastSID=last.SID                        # Dateiname

#Fritzbox
fritzbox=192.168.178.1
username=zabbix
passwort=123456
AINS=$1 # Aktor Identifikationsnummern der DECT200

########################################################################################
# ab hier nichts mehr anpassen
########################################################################################
# Verzeichnis + Dateiname
lastSID=$DatenDir/$lastSID

# SID Datei anlegen falls nicht vorhanden
touch $lastSID

# Alte SID lesen / Als Variable speichern
SID=$(cat $lastSID)

if [ "$3" = "1" ]; then
echo "lastSID ist $SID"
echo -----
fi

# Letze SID prüfen
loginA=$(curl http://$fritzbox/login_sid.lua?sid=$SID 2>/dev/null)
      if [ "$3" = "1" ]; then
      echo "loginA ist $loginA"
      echo -----
      fi
SID=$(sed -n -e 's/.*<SID>\(.*\)<\/SID>.*/\1/p' <<<$loginA )
      if [ "$3" = "1" ]; then
      echo SID ist $SID
      echo -----
      fi
# Dynamischer Passwort Salt lesen
Challenge=$(sed -n -e 's/.*<Challenge>\(.*\)<\/Challenge>.*/\1/p' <<<$loginA)
      if [ "$3" = "1" ]; then
      echo Challenge ist $Challenge
      echo -----
      fi

#Login nötig?
if [ "$SID" = "0000000000000000" ]
then
      if [ "$3" = "1" ]; then
      echo "SID ist nicht mehr gültig"
      echo "Login wird durchgeführt"
      echo -----
      fi
  PwString="$Challenge-$passwort"
     if [ "$3" = "1" ]; then
     echo PwString ist $PwString
     echo -----
     fi
  PwHash=$(echo -n "$PwString" |sed -e 's,.,&\n,g' | tr '\n' '\0' | md5sum | grep -o "[0-9a-z]\{32\}")
     if [ "$3" = "1" ]; then
     echo PwHash ist $PwHash
     echo -----
     fi
  response="$Challenge-$PwHash"
     if [ "$3" = "1" ]; then
     echo response ist $response
     echo -----
     fi
  loginB=$(curl -s "http://$fritzbox/login_sid.lua" -d "response=$response" -d 'username='${username} 2>/dev/null)
     if [ "$3" = "1" ]; then
     echo loginB ist $loginB
     echo -----
     fi
  SID=$(sed -n -e 's/.*<SID>\(.*\)<\/SID>.*/\1/p' <<<$loginB)
     if [ "$3" = "1" ]; then
     echo SID ist $SID
     echo -----
     fi
#echo "neue SID = $SID"
echo "$SID" >$lastSID
else
if [ "$3" = "1" ]; then
echo "Alte SID $SID ist noch gültig"
echo -----
fi
fi

# Schleife für alle AIN
for AIN in $AINS
do

if [ $2 = "Liste" ]; then
  # Liefert die kommaseparierte AIN/MAC Liste aller bekannten Steckdosen. Leer wenn keine Steckdose erkannt wird.
    Liste=`curl "http://$fritzbox/webservices/homeautoswitch.lua?ain=$AIN&switchcmd=getswitchlist&sid=$SID" 2>/dev/null `
    echo $Liste
elif [ $2 = "Zustand" ]; then
  # Ermittelt Schaltzustand der Steckdose
  # "0" oder "1" (Steckdose aus oder an), "inval" wenn unbekannt
    Zustand=`curl "http://$fritzbox/webservices/homeautoswitch.lua?ain=$AIN&switchcmd=getswitchstate&sid=$SID" 2>/dev/null `
    echo $Zustand
elif [ $2 = "Status" ]; then
  # Ermittelt Verbindungsstatus des Aktors ( 0 = nicht verbunden / 1 = verbunden ). Bei Verbindungsverlust wechselt der Zustand erst mit einigen Minuten Verzögerung zu 0.
    Status=`curl "http://$fritzbox/webservices/homeautoswitch.lua?ain=$AIN&switchcmd=getswitchpresent&sid=$SID" 2>/dev/null `
    echo $Status
elif [ $2 = "Leistung" ]; then
  # Aktuelle Leistung in mW abfragen. "inval" wenn unbekannt
    Leistung=`curl "http://$fritzbox/webservices/homeautoswitch.lua?ain=$AIN&switchcmd=getswitchpower&sid=$SID" 2>/dev/null `
    echo $Leistung
elif [ $2 = "Energie" ]; then
  # Stromverbrauch in Wh seit letztem Reset abfragen. "inval" wenn unbekannt.
    if [ "$3" = "1" ]; then
    echo Starte abfrage
    echo "curl http://$fritzbox/webservices/homeautoswitch.lua?ain=$AIN&switchcmd=getswitchenergy&sid=$SID"
    echo -----
    fi
    Energie=`curl "http://$fritzbox/webservices/homeautoswitch.lua?ain=$AIN&switchcmd=getswitchenergy&sid=$SID" 2>/dev/null `
    echo $Energie
elif [ $2 = "Name" ]; then
  # Bezeichnung des Aktors (in der FritzBox)
    Name=`curl "http://$fritzbox/webservices/homeautoswitch.lua?ain=$AIN&switchcmd=getswitchname&sid=$SID" 2>/dev/null `
    echo $Name
elif [ $2 = "Infos" ]; then
  # Liefert die grundlegenenden Informationen aller SmartHome-Geräte im XML Format.
    Infos=`curl "http://$fritzbox/webservices/homeautoswitch.lua?ain=$AIN&switchcmd=getdevicelistinfo&sid=$SID" 2>/dev/null `
    echo $Infos
elif [ $2 = "Temperatur" ]; then
  # Temperatur abfrage in 0,1°C. Negativ und positiv Möglich. "200" bedeutet 20°C.
    Temperatur=`curl "http://$fritzbox/webservices/homeautoswitch.lua?ain=$AIN&switchcmd=gettemperature&sid=$SID" 2>/dev/null `
    echo $Temperatur
elif [ $2 = "Solltemperatur" ]; then
  # Für HKR aktuell einstellte Solltemperatur in 0,5 °C. Wertbereich 16-56 -> 8 - 28°C. 16 <= 8°C, 17 = 8,5°C .... 56 >= 28°C.  254 = ON  253 = OFF
    Solltemperatur=`curl "http://$fritzbox/webservices/homeautoswitch.lua?ain=$AIN&switchcmd=gethkrtsoll&sid=$SID" 2>/dev/null `
    echo $Solltemperatur
elif [ $2 = "Komforttemperatur" ]; then
  # Für HKR aktuell einstellte Komforttemperatur in 0,5 °C. Wertbereich 16-56 -> 8 - 28°C. 16 <= 8°C, 17 = 8,5°C .... 56 >= 28°C.  254 = ON  253 = OFF
    Komforttemperatur=`curl "http://$fritzbox/webservices/homeautoswitch.lua?ain=$AIN&switchcmd=gethkrkomfort&sid=$SID" 2>/dev/null `
    echo $Komforttemperatur
elif [ $2 = "Spartemperatur" ]; then
  # Für HKR aktuell einstellte Spartemperatur in 0,5 °C. Wertbereich 16-56 -> 8 - 28°C. 16 <= 8°C, 17 = 8,5°C .... 56 >= 28°C.  254 = ON  253 = OFF
    Spartemperatur=`curl "http://$fritzbox/webservices/homeautoswitch.lua?ain=$AIN&switchcmd=gethkrabsenk&sid=$SID" 2>/dev/null `
    echo $Spartemperatur
fi
done
