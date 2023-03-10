#!/usr/bin/env bash
set -e

echo -e "\n------------------ Starting XFCE ------------------"

### disable screensaver and power management
xset -dpms &
xset s noblank &
xset s off &

/usr/bin/startxfce4 --replace > $HOME/wm.log &
cat $HOME/wm.log