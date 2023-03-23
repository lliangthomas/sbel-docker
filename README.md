# SBEL Docker noVNC
SBEL Docker Containers with Ubuntu 22.04 + NVIDIA + VNC + noVNC + Project Chrono

## Requirements
NVIDIA GPU, Up-to-date NVIDIA drivers, 16GB+ RAM

## Instructions
**Pull + Run**
```
docker pull uwsbel/chrono-noVNC
docker run -d -p 5901:5901 -p 6901:6901 --gpus all uwsbel/chrono-noVNC
```
Then, navigate to your modern browser and type ```localhost:6901```

**Password**: sbel

**Start, Stop, Remove**
```
docker start <container-name>
docker stop <container-name>
docker remove <container-name>
```
