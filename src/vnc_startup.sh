#!/bin/bash
set -e

# Shutdown signal
cleanup () {
    kill -s SIGTERM $!
    exit 0
}
trap cleanup SIGINT SIGTERM

## resolve_vnc_connection
VNC_IP=$(hostname -i)

## VNC password
mkdir -p "$HOME/.vnc"
PASSWD_PATH="$HOME/.vnc/passwd"
rm -f $PASSWD_PATH

echo "$VNC_PW" | vncpasswd -f >> $PASSWD_PATH
chmod 600 $PASSWD_PATH

# noVNC
$NO_VNC_HOME/utils/novnc_proxy --vnc localhost:$VNC_PORT --listen $NO_VNC_PORT > $STARTUPDIR/no_vnc_startup.log 2>&1 &
PID_SUB=$!

# VNC
vncserver -kill $DISPLAY &> $STARTUPDIR/vnc_startup.log \
    || rm -rfv /tmp/.X*-lock /tmp/.X11-unix &> $STARTUPDIR/vnc_startup.log \
    || echo "no locks present"

vnc_cmd="vncserver $DISPLAY -depth $VNC_COL_DEPTH -geometry $VNC_RESOLUTION PasswordFile=$HOME/.vnc/passwd"
$vnc_cmd > $STARTUPDIR/no_vnc_startup.log 2>&1

# XFCE
$HOME/wm_startup.sh &> $STARTUPDIR/wm_startup.log
wait $PID_SUB
