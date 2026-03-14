#!/bin/bash
# Log-Datei für nm-applet Start
LOG_FILE="/tmp/nm-applet-i3-startup.log"

# Erstelle die Log-Datei und schreibe den Startzeitpunkt
echo "Starting nm-applet at $(date)" >"$LOG_FILE" 2>&1

# Starte nm-applet mit einer kleinen Verzögerung und leite seine Ausgabe auch um
sleep 2 >>"$LOG_FILE" 2>&1
/usr/bin/nm-applet >>"$LOG_FILE" 2>&1 &

# Schreibe, ob der Befehl erfolgreich abgeschickt wurde
echo "nm-applet command sent to background at $(date)" >>"$LOG_FILE" 2>&1
