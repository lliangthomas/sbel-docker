FROM ubuntu:20.04

## Connection ports for controlling the UI:
# VNC port:5901
# noVNC webport, connect via http://IP:6901/?password=vncpassword
ENV DISPLAY=:1 \
    VNC_PORT=5901 \
    NO_VNC_PORT=6901
EXPOSE $VNC_PORT $NO_VNC_PORT

### Environment config
ENV HOME=/sbel \
    TERM=xterm \
    STARTUPDIR=/dockerstartup \
    NO_VNC_HOME=/sbel/noVNC \
    DEBIAN_FRONTEND=noninteractive \
    VNC_COL_DEPTH=24 \
    VNC_RESOLUTION=1280x1024 \
    VNC_PW=vncpassword \
    VNC_VIEW_ONLY=false
WORKDIR $HOME

### Install Basics, VNC server, noVNC
RUN apt update \
    && apt install -y --no-install-recommends --allow-unauthenticated \
        vim wget net-tools bzip2 procps python3-numpy \
        tigervnc-standalone-server \
    && apt autoclean -y \
    && apt autoremove -y \
    && rm -rf /var/lib/apt/lists/*

### Install noVNC
RUN mkdir -p $NO_VNC_HOME/utils/websockify \
    && wget -qO- https://github.com/novnc/noVNC/archive/refs/tags/v1.3.0.tar.gz \ 
    | tar xz --strip 1 -C $NO_VNC_HOME \ 
    && wget -qO- https://github.com/novnc/websockify/archive/refs/tags/v0.10.0.tar.gz \ 
    | tar xz --strip 1 -C $NO_VNC_HOME/utils/websockify \
    && ln -s $NO_VNC_HOME/vnc_lite.html $NO_VNC_HOME/index.html

### Install XFCE
RUN apt-get update \
    && apt install -y --no-install-recommends --allow-unauthenticated \
    supervisor xfce4 xfce4-terminal xterm dbus-x11 libdbus-glib-1-2 \
    && apt purge -y pm-utils *screensaver* \
    && apt autoclean -y \
    && apt autoremove -y \
    && rm -rf /var/lib/apt/lists/*

ADD ./src/common/xfce/ $HOME/

### Install nss-wrapper to execute image as non-root user"
RUN apt-get update \
    && apt install -y --no-install-recommends --allow-unauthenticated \
    libnss-wrapper gettext \
    && apt autoclean -y \
    && apt autoremove -y \
    && rm -rf /var/lib/apt/lists/*
### Startup
ADD ./src/vnc_startup.sh $STARTUPDIR
ADD ./src/set_user_permission.sh 
RUN $INST_SCRIPTS/set_user_permission.sh $STARTUPDIR $HOME

USER 1000

ENTRYPOINT ["/dockerstartup/vnc_startup.sh"]
CMD ["--wait"]