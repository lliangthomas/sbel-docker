#!/bin/bash
set -e

# Shutdown signal
cleanup () {
    kill -s SIGTERM $!
    exit 0
}
trap cleanup SIGINT SIGTERM

VNC_IP=$(hostname -i)

## VNC password
mkdir -p "$HOME/.vnc"
PASSWD_PATH="$HOME/.vnc/passwd"
rm -f $PASSWD_PATH

echo "$VNC_PW" | vncpasswd -f >> $PASSWD_PATH
chmod 600 $PASSWD_PATH

# noVNC
$NO_VNC_HOME/utils/novnc_proxy --vnc localhost:$VNC_PORT --listen $NO_VNC_PORT &
PID_SUB=$!

# VNC
vncserver -kill $DISPLAY & \
    || rm -rfv /tmp/.X*-lock /tmp/.X11-unix &

vncserver $DISPLAY -depth $VNC_COL_DEPTH -geometry $VNC_RESOLUTION PasswordFile=$HOME/.vnc/passwd &

# XFCE
$HOME/wm_startup.sh &
wait $PID_SUB
