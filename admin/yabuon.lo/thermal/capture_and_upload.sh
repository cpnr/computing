#!/bin/bash
set -euo pipefail

## Prepare output directory
TMPDIR=/tmp/thermal
mkdir -p $TMPDIR

## Capture image from the thermal camera
export PYTHONPATH=/home/hep/.local/lib/python3.13/site-packages
/home/hep/admin/thermal/thermal.py -m render -o $TMPDIR/cam.png

## Upload latest image
REMOTEUSER=support
REMOTEHOST=hep.lo
REMOTEPATH=/srv/storage/raid1/k8s/volumes/www-html/system/thermal

KEY=/home/hep/.ssh/id_ed25519

rsync -az -e "ssh -p 2223 -i $KEY -o BatchMode=yes -o StrictHostKeyChecking=yes" \
      $TMPDIR/cam.png $REMOTEUSER@$REMOTEHOST:$REMOTEPATH/latest.png

## Archive image-of-the day
DAY="$(date +%F)"
STAMP="$(date +%F_%H-%M-%S)"
if ! ssh -i $KEY -p 2223 -o BatchMode=yes -o StrictHostKeyChecking=yes \
         $REMOTEUSER@$REMOTEHOST "ls $REMOTEPATH/${DAY}_*.png > /dev/null 2>&1"; then
  rsync -az -e "ssh -p 2223 -i $KEY -o BatchMode=yes -o StrictHostKeyChecking=yes" \
        $TMPDIR/cam.png $REMOTEUSER@$REMOTEHOST:$REMOTEPATH/${STAMP}.png
  echo "Upload new daily image"
else
  echo "Image already exists on server"
fi
