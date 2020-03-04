# opencv-golang
Container with tools for OpenCV, Golang and Python along with support on XWindow export for development purposes

Container contents:
  * OpenCV 4.2 - compiled with FFMPEG and GStreamer
  * Golang 1.13 tool chain
  * Python 3.8
  * SSH server prepared for login with user/password root/root

## Optimize image size

You can optimize this image size by squashing all layers

* Create docker-compose.yml:

```yml
version: '3.7'
services:
  docker-squash:
    image: flaviostutz/docker-squash
    environment:
      - SOURCE_IMAGE_ID=flaviostutz/opencv-golang:1.0.2
      - TARGET_IMAGE_TAG=1.0.2-squashed
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
```

* Run ```docker-compose up```

* Push the new image to Dockerhub

```docker push flaviostutz/opencv-golang:1.0.2-squashed```

* More info at https://github.com/jwilder/docker-squash

## Tips on OpenCV applications development

It's common to use OpenCV native windows for debugging during development of CV applications. You can use X-Window export to run OpenCV inside the container and at the same time view those windows in your machine by connecting to the container through SSH with X export enabled.

For doing this, follow the steps:
  * Start X server on you machine (XQuartz in MacOS)
  * Start container with "docker run --privileged -p 2222:22 flaviostutz/opencv-golang"
  * From your machine, connect to the container using "ssh -Y -p 2222 root@[CONTAINER HOST]"
  * Once in SSH session, run an application, such as "/go/bin/test" that will show a feed from the Internet in a Window exported to your host machine

