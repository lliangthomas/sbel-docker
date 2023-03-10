FROM nvidia/cuda:11.8.0-devel-ubuntu22.04

############################################
# Pre-defined and environmental variables
############################################
ENV DISPLAY=:1 \
    VNC_PORT=5901 \
    NO_VNC_PORT=6901
EXPOSE $VNC_PORT $NO_VNC_PORT

ENV HOME=/sbel \
    TERM=xterm \
    STARTUPDIR=/sbel-start \
    INST_SCRIPTS=/sbel/install \
    NO_VNC_HOME=/noVNC \
    DEBIAN_FRONTEND=noninteractive \
    VNC_COL_DEPTH=24 \
    VNC_RESOLUTION=1280x1024
WORKDIR $HOME

############################################
# Install pre-requisite packages
############################################
RUN apt-get update \ 
  && apt-get -y install git wget net-tools bzip2 procps python3-numpy \
  && apt autoclean -y \
  && apt autoremove -y \
  && rm -rf /var/lib/apt/lists/*

############################################
# Install XFCE
############################################
RUN apt-get update \ 
  && apt-get install -y supervisor xfce4 xfce4-terminal xterm dbus-x11 libdbus-glib-1-2 \
  && apt-get purge -y pm-utils *screensaver* \
  && apt autoclean -y \
  && apt autoremove -y \
  && rm -rf /var/lib/apt/lists/*

############################################
# Install noVNC
############################################
RUN mkdir -p $NO_VNC_HOME/utils/websockify
RUN wget -qO- https://github.com/novnc/noVNC/archive/refs/tags/v1.3.0.tar.gz | tar xz --strip 1 -C $NO_VNC_HOME
RUN wget -qO- https://github.com/novnc/websockify/archive/refs/tags/v0.10.0.tar.gz | tar xz --strip 1 -C $NO_VNC_HOME/utils/websockify
RUN ln -s $NO_VNC_HOME/vnc_lite.html $NO_VNC_HOME/index.html

############################################
# Install Chrono dependencies
############################################
RUN apt-get update \ 
  && apt-get -y install cmake ninja-build build-essential libboost-dev swig libeigen3-dev \ 
  libglfw3-dev libglm-dev libglew-dev freeglut3-dev libirrlicht-dev \
  libxxf86vm-dev libopenmpi-dev python3 python3-dev libhdf5-dev libnvidia-gl-515 \
  && apt autoclean -y \
  && apt autoremove -y \
  && rm -rf /var/lib/apt/lists/*
RUN ldconfig

RUN wget https://bitbucket.org/blaze-lib/blaze/downloads/blaze-3.8.tar.gz \
  && tar -xf blaze-3.8.tar.gz \
  && cp -r blaze-3.8/blaze /usr/local/include \
  && rm -rf blaze*

############################################
# Build Vanilla Chrono Release 8.0 without Tests
############################################
RUN git clone --recursive https://github.com/projectchrono/chrono.git -b release/8.0
RUN cd chrono \
  && mkdir -p build \
  && cd build \
  && cmake ../ -G "Ninja" -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTING=OFF \
    -DBUILD_BENCHMARKING=OFF -DENABLE_MODULE_POSTPROCESS=TRUE \ 
    -DENABLE_MODULE_PYTHON=TRUE -DENABLE_MODULE_COSIMULATION=FALSE \ 
    -DENABLE_MODULE_IRRLICHT=TRUE -DENABLE_MODULE_VEHICLE=TRUE \
    -DENABLE_MODULE_MULTICORE=TRUE -DENABLE_MODULE_OPENGL=TRUE \
    -DENABLE_MODULE_FSI=TRUE -DENABLE_MODULE_SYNCHRONO=TRUE \
    -DENABLE_MODULE_CSHARP=TRUE -DENABLE_MODULE_GPU=TRUE \
    -DENABLE_MODULE_DISTRIBUTED=TRUE \
    -DENABLE_HDF5=TRUE \
    -DCMAKE_C_COMPILER=/usr/bin/gcc \
    -DCMAKE_CXX_COMPILER=/usr/bin/g++ \
    -DCUDA_HOST_COMPILER=/usr/bin/gcc \
    -DPYTHON_EXECUTABLE=/usr/bin/python3 \
    -DEIGEN3_INCLUDE_DIR=/usr/include/eigen3 \
    -DCMAKE_VERBOSE_MAKEFILE=TRUE \
    -DENABLE_MODULE_SENSOR=OFF \ 
  && ninja -j 8 \
  && ninja install

############################################
# Add necesary files
############################################
ADD ./src/ $STARTUPDIR

############################################
# Start Container
############################################
ENTRYPOINT ["/sbel-start/startup.sh"]

############################################
# Instructions on running the container:
# docker run -it -p 6901:6901 <container tag name>
############################################