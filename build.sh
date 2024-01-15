#!/bin/bash -x

WORK=$(mktemp -d)
RELEASE=$(mktemp -d)
mkdir -p $WORK/build

xcodebuild archive -configuration Release -project wallman_app.xcodeproj -scheme 'Wallpaper Manager' -archivePath $WORK/build

APP=$(find $WORK -name 'Wallpaper Manager.app')
pushd "$(dirname "$APP")"
tar cvzf  "$WORK/wallman.tar.gz" "$(basename "$APP")"
popd

echo $WORK

ls -l $WORK
