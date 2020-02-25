# FROM czentye/opencv-video-minimal:4.2-py3.7.5
FROM golang:1.14-rc-alpine



## OPENCV 4.2
RUN apk --update add git alpine-sdk cmake linux-headers
RUN go get -u -d gocv.io/x/gocv
WORKDIR $GOPATH/src/gocv.io/x/gocv

# remove this after https://github.com/hybridgroup/gocv/pull/621 is accepted
RUN sed -i 's/-DOPENCV_/-D OPENCV_/' Makefile

# RUN make install
RUN make download
RUN make build
RUN make sudo_install

# remove this after https://github.com/czeni/opencv-video-minimal/pull/6 is accepted
ENV PKG_CONFIG_PATH /usr/local/lib64/pkgconfig
ENV LD_LIBRARY_PATH /usr/local/lib64/:/usr/local/include/
RUN ln -s /usr/local/include/opencv4/opencv2/ /usr/local/include/opencv2

RUN apk add pkgconfig
RUN go run ./cmd/version/main.go
# RUN apk del --purge alpine-sdk cmake linux-headers
RUN rm -rf /tmp/opencv/
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



ADD startup.sh /startup.sh

CMD [ "/startup.sh" ]
