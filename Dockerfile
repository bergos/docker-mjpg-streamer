FROM balenalib/rpi-raspbian

# install build tools, git, libjpeg and libraspberrypi for picam support
RUN apt-get update && apt-get install -y --no-install-recommends build-essential cmake git libjpeg8 libjpeg8-dev libraspberrypi0 libraspberrypi-dev

# clone the git repo without history
WORKDIR /usr/src
RUN git clone https://github.com/jacksonliam/mjpg-streamer.git --depth=1

# run the build
WORKDIR /usr/src/mjpg-streamer/mjpg-streamer-experimental
RUN make

# copy binaries and static files to opt
RUN mkdir -p /opt/mjpg-streamer && cp ./mjpg_streamer /opt/mjpg-streamer/ && cp ./*.so /opt/mjpg-streamer/ && cp -r ./www /opt/mjpg-streamer/ && rm -rf /usr/src/mjpg-streamer

# uninstall packages required only for build
RUN apt-get purge build-essential cmake git libjpeg8-dev libraspberrypi-dev && apt-get autoremove --purge && apt-get clean

#
EXPOSE 8080
WORKDIR /opt/mjpg-streamer
ENTRYPOINT ["./mjpg_streamer"]
