#!/bin/bash
set -euo pipefail

## Prepare output directory
TMPDIR=/tmp/rpicam
mkdir -p $TMPDIR

PORT=<SET THE PORT NUMBER OF THE SERVER>


## Capture image from the camera
WIDTH=640
HEIGHT=480
QUALITY=70
EXPOSURE=500000

rpicam-still -n --width $WIDTH --height $HEIGHT -q $QUALITY \
             --awbgains 1,1 --gain 16 --shutter $EXPOSURE \
             -o $TMPDIR/cam_raw.jpg
convert $TMPDIR/cam_raw.jpg -gravity NorthEast -pointsize 28 \
        \( -background white -fill black label:"$(date '+%F %T')" \) \
        -geometry +12+12 -composite \
        $TMPDIR/cam.jpg
rm -f $TMPDIR/cam_raw.jpg

## Upload latest image
REMOTEUSER=<REMOTE USER NAME>
REMOTEHOST=<REMOTE HOST NAME>
REMOTEPATH=<SET THE REMOTE PATH>

KEY=<SSH KEY FILE PATH>

rsync -az -e "ssh -p $PORT -i $KEY -o BatchMode=yes -o StrictHostKeyChecking=yes" \
      $TMPDIR/cam.jpg $REMOTEUSER@$REMOTEHOST:$REMOTEPATH/latest.jpg

## Archive image-of-the day
DAY="$(date +%F)"
STAMP="$(date +%F_%H-%M-%S)"
if ! ssh -i $KEY -p 2223 -o BatchMode=yes -o StrictHostKeyChecking=yes \
         $REMOTEUSER@$REMOTEHOST "ls $REMOTEPATH/${DAY}_*.jpg > /dev/null 2>&1"; then
  rsync -az -e "ssh -p $PORT -i $KEY -o BatchMode=yes -o StrictHostKeyChecking=yes" \
        $TMPDIR/cam.jpg $REMOTEUSER@$REMOTEHOST:$REMOTEPATH/${STAMP}.jpg
  echo "Upload new daily image"
else
  echo "Image already exists on server"
fi
