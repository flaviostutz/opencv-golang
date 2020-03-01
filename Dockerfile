# FROM czentye/opencv-video-minimal:4.2-py3.7.5
FROM golang:1.14.0-alpine3.11


## OPENCV 4.2
# extracted from github.com/czentye/opencv-video-minimal
# after https://github.com/czeni/opencv-video-minimal/pull/6/files is accepted, we could back to use its image
ENV LANG=C.UTF-8

ARG OPENCV_VERSION=4.2.0

RUN apk add --update --no-cache \
    # Build dependencies
    build-base clang clang-dev cmake pkgconf wget openblas openblas-dev \
    linux-headers gtk+2.0-dev \
    # Image IO packages
    libjpeg-turbo libjpeg-turbo-dev \
    libpng libpng-dev \
    libwebp libwebp-dev \
    tiff tiff-dev \
    # jasper-libs jasper-dev \
    openexr openexr-dev \
    # Video depepndencies
    ffmpeg-libs ffmpeg-dev \
    libavc1394 libavc1394-dev \
    gstreamer gstreamer-dev \
    gst-plugins-base gst-plugins-base-dev \
    libgphoto2 libgphoto2-dev && \
    apk add --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing \
            --update --no-cache libtbb libtbb-dev && \
    # Python dependencies
    apk add --repository http://dl-cdn.alpinelinux.org/alpine/edge/main \
            --update --no-cache python3 python3-dev && \
    #apk add --repository http://dl-cdn.alpinelinux.org/alpine/edge/community \
    #        --update --no-cache py-numpy py-numpy-dev && \
    # Update also musl to avoid an Alpine bug
    apk upgrade --repository http://dl-cdn.alpinelinux.org/alpine/edge/main musl && \
    # Make Python3 as default
    ln -vfs /usr/bin/python3 /usr/local/bin/python && \
    ln -vfs /usr/bin/pip3 /usr/local/bin/pip && \
    # Fix libpng path
    ln -vfs /usr/include/libpng16 /usr/include/libpng && \
    ln -vfs /usr/include/locale.h /usr/include/xlocale.h && \
    pip3 install -v --no-cache-dir --upgrade pip && \
    pip3 install -v --no-cache-dir numpy

RUN cd /tmp && \
    # Download OpenCV source
    wget https://github.com/opencv/opencv/archive/$OPENCV_VERSION.tar.gz && \
    tar -xvzf $OPENCV_VERSION.tar.gz && \
    rm -vrf $OPENCV_VERSION.tar.gz

RUN mkdir -vp /tmp/opencv-$OPENCV_VERSION/build && \
    # Configure
    cd /tmp/opencv-$OPENCV_VERSION/build && \
    cmake \
        # Compiler params
        -D CMAKE_BUILD_TYPE=RELEASE \
        -D CMAKE_C_COMPILER=/usr/bin/clang \
        -D CMAKE_CXX_COMPILER=/usr/bin/clang++ \
        -D CMAKE_INSTALL_PREFIX=/usr \
        # No examples
        -D INSTALL_PYTHON_EXAMPLES=NO \
        -D INSTALL_C_EXAMPLES=NO \
        # Support
        -D WITH_IPP=NO \
        -D WITH_1394=NO \
        -D WITH_LIBV4L=NO \
        -D WITH_V4l=YES \
        -D WITH_TBB=YES \
        -D WITH_FFMPEG=YES \
        -D WITH_GPHOTO2=YES \
        -D WITH_GSTREAMER=YES \
        # NO doc test and other bindings
        -D BUILD_DOCS=NO \
        -D BUILD_TESTS=NO \
        -D BUILD_PERF_TESTS=NO \
        -D BUILD_EXAMPLES=NO \
        -D BUILD_opencv_java=NO \
        -D BUILD_opencv_python2=NO \
        -D BUILD_ANDROID_EXAMPLES=NO \
        # Build Python3 bindings only
        -D PYTHON3_LIBRARY=`find /usr -name libpython3.so` \
        -D PYTHON_EXECUTABLE=`which python3` \
        -D PYTHON3_EXECUTABLE=`which python3` \
        -D OPENCV_GENERATE_PKGCONFIG=ON \
        -D BUILD_opencv_python3=YES .. && \
    # Build
    make -j`grep -c '^processor' /proc/cpuinfo` && \
    make install

RUN cd / && rm -vrf /tmp/opencv-$OPENCV_VERSION && \
    # Cleanup
    apk del --purge clang clang-dev wget openblas-dev \
                    openexr-dev gstreamer-dev gst-plugins-base-dev libgphoto2-dev \
                    libtbb-dev libjpeg-turbo-dev libpng-dev tiff-dev \
                    ffmpeg-dev libavc1394-dev python3-dev && \
                    rm -vrf /var/cache/apk/*

ENV PKG_CONFIG_PATH /usr/lib64/pkgconfig
ENV LD_LIBRARY_PATH /usr/lib64/:/usr/include/
## OPENCV 4.2



## SSH FOR XWINDOW EXPORT
RUN apk --update add openssh xauth
RUN mkdir /var/run/sshd \
    && echo 'root:root' | chpasswd \
    && sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config \
    && sed -i 's/X11Forwarding no/X11Forwarding yes/' /etc/ssh/sshd_config \
    && sed -i 's/#X11UseLocalhost yes/X11UseLocalhost no/' /etc/ssh/sshd_config
ADD ssh-envs.sh /etc/profile.d/
EXPOSE 22
## SSH FOR XWINDOW EXPORT



### COMPILE TEST
RUN mkdir /test
WORKDIR /test

ADD go.mod .
RUN go mod download

ADD . ./
RUN go build -o /go/bin/test
### COMPILE TEST



ADD start-ssh.sh /

CMD [ "/start-ssh.sh" ]
