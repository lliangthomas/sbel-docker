#####################################################
# Pre-Build for Chrono
#####################################################
FROM uwsbel/ubuntu_packages_image AS builder
RUN export LIB_DIR="lib" && export IOMP5_DIR="" \
    && apt-get update && apt-get -y install unzip python3 python3-pip \
      git cmake ninja-build doxygen libvulkan-dev pkg-config \
      freeglut3-dev mpich libasio-dev libboost-dev \
      libtinyxml2-dev swig python3-dev libhdf5-dev libnvidia-gl-515 \
    && ldconfig \
    && wget -O- https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB | \
      gpg --dearmor | tee /usr/share/keyrings/oneapi-archive-keyring.gpg > /dev/null \
    && echo "deb [signed-by=/usr/share/keyrings/oneapi-archive-keyring.gpg] \
      https://apt.repos.intel.com/oneapi all main" | tee /etc/apt/sources.list.d/oneAPI.list \ 
    && apt update \ 
    && apt -y install intel-basekit libxcb-randr0-dev libxcb-xtest0-dev libxcb-xinerama0-dev
      libxcb-shape0-dev libxcb-xkb-dev xorg-dev \
    && cd ~/Packages/opencascade-7.4.0/build \ 
    && cmake -DBUILD_MODULE_Draw:BOOL=FALSE .. \
    && make -j 8 \ 
    && make install -j 8 \
    && mkdir -p /builds/uwsbel && cd /builds/uwsbel \ 
    && git clone https://github.com/projectchrono/chrono.git --recursive \
    && cd chrono && git submodule init && git submodule update && mkdir build \
    && export C_COMPILER="/usr/bin/gcc" && export CXX_COMPILER="/usr/bin/g++" \
    && cmake -G "Ninja" -B $CI_PROJECT_DIR/build/ -S $CI_PROJECT_DIR --preset=linuxci \ 
    && cd build \
    && ninja -j 8

#####################################################
# Docker Image and Install builder Chrono
#####################################################
FROM uwsbel/ubuntu_packages_image
WORKDIR /
RUN export LIB_DIR="lib" && export IOMP5_DIR="" \
    && apt-get update && apt-get -y install unzip python3 python3-pip \
      git cmake ninja-build doxygen libvulkan-dev pkg-config \
      freeglut3-dev mpich libasio-dev libboost-dev \
      libtinyxml2-dev swig python3-dev libhdf5-dev libnvidia-gl-515 \
    && ldconfig 
COPY --from=builder /builds .
RUN cd /builds/uwsbel/chrono/build && make install 

#####################################################
# Pre-defined and environmental variables
#####################################################
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
    VNC_PW=sbel \
    LANG='en_US.UTF-8' \
    LANGUAGE='en_US:en' \
    LC_ALL='en_US.UTF-8'
EXPOSE $VNC_PORT $NO_VNC_PORT

#####################################################
# Install prerequisities
#####################################################
RUN apt-get update && apt-get install -y net-tools wget locales bzip2 procps python3-numpy \
    && apt-get clean -y && locale-gen en_US.UTF-8

#####################################################
# Install TigerVNC, noVNC, XFCE
#####################################################
    # TigerVNC
RUN apt-get update && apt-get install -y tigervnc-standalone-server \
    && printf '\n# sbel-docker:\n$localhost = "no";\n1;\n' >>/etc/tigervnc/vncserver-config-defaults \
    # noVNC
    && mkdir -p $NO_VNC_HOME/utils/websockify \
    && wget -qO- https://github.com/novnc/noVNC/archive/refs/tags/v1.3.0.tar.gz | tar xz --strip 1 -C $NO_VNC_HOME \
    && wget -qO- https://github.com/novnc/websockify/archive/refs/tags/v0.10.0.tar.gz | tar xz --strip 1 -C $NO_VNC_HOME/utils/websockify \ 
    && ln -s $NO_VNC_HOME/vnc_lite.html $NO_VNC_HOME/index.html \
    # XFCE
    && apt-get install -y supervisor xfce4 xfce4-terminal xterm dbus-x11 libdbus-glib-1-2 \
    && apt-get purge -y pm-utils *screensaver* \
    # Ensure $STARTUPDIR exists
    && mkdir $STARTUPDIR

#ADD artifacts.zip $HOME/chrono/
#RUN apt install libeigen3-dev
#RUN cd $HOME/chrono && unzip artifacts.zip && cd build && ninja install
ADD ./scripts/ $HOME/scripts/
RUN chmod a+x $HOME/scripts/vnc_startup.sh $HOME/scripts/wm_startup.sh

ENTRYPOINT ["/sbel/scripts/vnc_startup.sh"]