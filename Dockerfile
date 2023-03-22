FROM nvidia/cuda:11.8.0-devel-ubuntu22.04

############################################
# Pre-defined and environmental variables
############################################
ENV DISPLAY=:1 \
    VNC_PORT=5901 \
    NO_VNC_PORT=6901 \
    HOME=/sbel \
    TERM=xterm \
    STARTUPDIR=/dockerstartup \
    NO_VNC_HOME=/sbel/noVNC \
    DEBIAN_FRONTEND=noninteractive \
    VNC_COL_DEPTH=24 \
    VNC_RESOLUTION=1280x1024 \
    VNC_PW=sbel
EXPOSE $VNC_PORT $NO_VNC_PORT
WORKDIR $HOME

############################################
# Install prerequisities
############################################
RUN apt-get update && apt-get install -y wget net-tools locales bzip2 procps python3-numpy \
    && apt-get clean -y && locale-gen en_US.UTF-8
ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'

############################################
# Install TigerVNC, noVNC, XFCE
############################################
RUN apt-get update && apt-get install -y tigervnc-standalone-server \
    && printf '\n# docker-headless-vnc-container:\n$localhost = "no";\n1;\n' >>/etc/tigervnc/vncserver-config-defaults \
    && mkdir -p $NO_VNC_HOME/utils/websockify \
    && wget -qO- https://github.com/novnc/noVNC/archive/refs/tags/v1.3.0.tar.gz | tar xz --strip 1 -C $NO_VNC_HOME \
    && wget -qO- https://github.com/novnc/websockify/archive/refs/tags/v0.10.0.tar.gz | tar xz --strip 1 -C $NO_VNC_HOME/utils/websockify \ 
    && ln -s $NO_VNC_HOME/vnc_lite.html $NO_VNC_HOME/index.html \
    && apt-get install -y supervisor xfce4 xfce4-terminal xterm dbus-x11 libdbus-glib-1-2 \
    && apt-get purge -y pm-utils *screensaver* \
    && apt-get clean -y && mkdir $STARTUPDIR
ADD ./src/home/ $HOME/

############################################
# Startup
############################################
RUN $HOME/set_user_permission.sh $STARTUPDIR $HOME

ENTRYPOINT ["/sbel/vnc_startup.sh"]
CMD ["--wait"]
