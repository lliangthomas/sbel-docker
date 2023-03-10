#!/usr/bin/env bash
source $HOME/.bashrc
VNC_IP=$(hostname -i)

############################################
# Start noVNC
############################################
$NO_VNC_HOME/utils/novnc_proxy --vnc localhost:$VNC_PORT --listen $NO_VNC_PORT > $STARTUPDIR/no_vnc_startup.log 2>&1 &
PID_SUB=$!
vnc_cmd="vncserver $DISPLAY -depth $VNC_COL_DEPTH -geometry $VNC_RESOLUTION"
$vnc_cmd > $STARTUPDIR/no_vnc_startup.log 2>&1

############################################
# Start XFCE
############################################
$HOME/wm_startup.sh &> $STARTUPDIR/wm_startup.log

echo -e "\nnoVNC HTML client started:\n\t=> connect via http://$VNC_IP:$NO_VNC_PORT/?password=...\n"
