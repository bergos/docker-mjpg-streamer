# docker-mjpg-streamer

Dockerfile for [mjpg-streamer](https://github.com/jacksonliam/mjpg-streamer) on the Raspberry PI.

## Build

The image must be built for the `arm/v6` platform to run it on a Raspberry PI.

This can be done by running the build on a Raspberry PI:

```bash
docker build --squash --tag=mjpg-streamer .
```

The Dockerfile will remove dependencies required only for the build step at the end.
The intermediate files can be excluded from the final image using the `--squash` option.
That will reduce the image size by a few 10MBs.

If the build is done on the target machine and the target machine is a Pi Zero, the build can take quite some time.
An alternative is [buildx](https://github.com/docker/buildx), a Docker CLI plugin for cross platform builds.
Check the documentation how to setup up a builder instance for the `arm/v6` platform.
Once the builder is ready, you can build the image with the following command, which will also import the image to the local registry:

```bash
docker buildx build --load --tag=mjpg-streamer .
```

## Run

The image always requires a command to select the matching input plugin for your camera and the output plugin.
Check the `mjpg-streamer` documentation for more infos about the plugins and options for the plugins.
USB cameras and the [Raspberry PI Camera Module V2](https://www.raspberrypi.org/products/camera-module-v2/) have been successfully tested.
For hardware access, the container must have access to the video device.
Last but not least the port of the output plugin must be exported.

### Raspberry PI Camera Module

The following docker compose file can be used for a PI Camera Module.
The `devices` are specific for the PI Camera Module.

```yaml
version: '3'
services:
  mjpg-streamer:
    container_name: mjpg-streamer
    image: mjpg-streamer
    restart: unless-stopped
    command: "-i 'input_raspicam.so' -o 'output_http.so -w ./www'"
    devices:
      - "/dev/vchiq:/dev/vchiq"
      - "/dev/vcsm:/dev/vcsm"
    ports:
      - "8080:8080"
```

### USB camera

The following docker compose file can be used for a USB camera.
On a Pi Zero the CPU load can be quite high.
To reduce the CPU load the `--every_frame` option can be useful.

```yaml
version: '3'
services:
  mjpg-streamer:
    container_name: mjpg-streamer
    image: mjpg-streamer
    restart: unless-stopped
    command: "-i 'input_uvc.so --resolution 1920x1080' -o 'output_http.so -w ./www'"
    devices:
      - "/dev/video0:/dev/video0"
    ports:
      - "8080:8080"
```
