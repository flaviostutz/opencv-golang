package main

import (
	"gocv.io/x/gocv"
)

func main() {

	print("Opening video feed...")
	cam, err := gocv.OpenVideoCapture("http://87.57.111.162/mjpg/video.mjpg")
	if err != nil {
		panic("Error in opening feed: " + err.Error())
	}

	window := gocv.NewWindow("Hello")
	img := gocv.NewMat()

	for {
		cam.Read(&img)
		window.IMShow(img)
		window.WaitKey(1)
	}

}
