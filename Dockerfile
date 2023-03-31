FROM uwsbel/ubuntu_packages_image:latest

RUN export LIB_DIR="lib" && export IOMP5_DIR="" \
    && apt-get update && apt-get -y install unzip wget python3 python3-pip \
      git cmake ninja-build doxygen libvulkan-dev pkg-config libirrlicht-dev \
      freeglut3-dev mpich libasio-dev libboost-dev libglfw3-dev libglm-dev \
      libglew-dev libtinyxml2-dev swig python3-dev libhdf5-dev libnvidia-gl-515 \
    && ldconfig

ADD artifacts.zip $HOME/chrono/
