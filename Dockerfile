FROM uwsbel/ubuntu_packages_image:latest

RUN export LIB_DIR="lib" && export IOMP5_DIR="" \
    && apt-get update && apt-get -y install unzip wget python3 python3-pip \
      git cmake ninja-build doxygen libvulkan-dev pkg-config libirrlicht-dev \
      freeglut3-dev mpich libasio-dev libboost-dev libglfw3-dev libglm-dev \
      libglew-dev libtinyxml2-dev swig python3-dev libhdf5-dev libnvidia-gl-515 \
    && ldconfig \
    && wget -O- https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB | \
      gpg --dearmor | tee /usr/share/keyrings/oneapi-archive-keyring.gpg > /dev/null \
    && echo "deb [signed-by=/usr/share/keyrings/oneapi-archive-keyring.gpg] https://apt.repos.intel.com/oneapi all main" | tee /etc/apt/sources.list.d/oneAPI.list \
    && apt-get update && apt -y install intel-basekit libxcb-randr0-dev libxcb-xtest0-dev libxcb-xinerama0-dev \
      libxcb-shape0-dev libxcb-xkb-dev xorg-dev \
    && cd ~/Packages/opencascade-7.4.0/build \
    && cmake -DBUILD_MODULE_Draw:BOOL=FALSE .. \
    && make -j 8 \
    && make install -j 8

RUN git clone https://github.com/projectchrono/chrono.git --recursive \
    && cd chrono \
    && git submodule init \
    && git submodule update \
    && mkdir -p build \
    && export C_COMPILER="/usr/bin/gcc" && export CXX_COMPILER="/usr/bin/g++" \ 
    && cmake -G "Ninja" -B build/ -S . --preset=linuxci \
    && ninja install