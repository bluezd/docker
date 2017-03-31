#!/bin/bash

buildImage() {
	echo "Building image $IMAGE_NAME..."

	USER=`whoami`
	if [[ $USER != "root" ]]; then
		sudo docker build --force-rm=True --no-cache=True -t $IMAGE_NAME .
	else
		docker build --force-rm=True --no-cache=True -t $IMAGE_NAME .
	fi
}

runImage() {
	echo "Running image $IMAGE_NAME..."

	USER=`whoami`
	if [[ $USER != "root" ]]; then
		sudo docker run --name $IMAGE_NAME -d -p 8788:8788 $IMAGE_NAME 
	else
		docker run --name $IMAGE_NAME -d -p 8788:8788 $IMAGE_NAME 
	fi
}

usage() {
cat << EOF
Usage: run.sh [-b | -r]
Build and Run a Docker image for shadowsocks.

Parameter:
   -b: build the image.
   -r: run the image.

EOF
exit 0
}

if [ "$#" -eq 0 ]; then
	usage
fi

while getopts "hb:r:" optname;
do
	case "$optname" in
		"h")
			usage
			;;
		"b")
			echo "buildImage"
			buildImage
			;;
		"r")
			echo "runImage"
			runImage
			;;
		*)
			echo "Invalid option !!"
			exit 1
	esac
done
