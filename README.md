# opencv-golang
Container with tools for OpenCV and Golang along with support on XWindow export for development purposes

Container contents:
  * OpenCV 4.2 runtime
  * Golang 1.13 tool chain
  * SSH server prepared for login with user/password root/root

## Tips on OpenCV applications development

It's common to use OpenCV native windows for debugging during development of CV applications. You can use X-Window export to run OpenCV inside the container and at the same time view those windows in your machine by connecting to the container through SSH with X export enabled.

For doing this, follow the steps:
  * Start X server on you machine (XQuartz in MacOS)
  * Start container with "docker run --privileged -p 2222:22 flaviostutz/opencv-golang"
  * From your machine, connect to the container using "ssh -Y -p 2222 root@[CONTAINER HOST]"
  * Once in SSH session, run an application, such as "[OpenCV]/facedetect.py --cascade cascade.xml". It will open your webcam and show its contents on a X-Window on your machine

