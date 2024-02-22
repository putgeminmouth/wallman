#!/bin/bash

function die {
    echo "$@"
    exit 1
}

git diff --exit-code >/dev/null || die "Cannot build with local changes!"

WORK=$(mktemp -d)
RELEASE=$(mktemp -d)
mkdir -p $WORK/build

echo "Building..."
xcodebuild archive -configuration Release -project wallman_app.xcodeproj -scheme 'Wallpaper Manager' -archivePath $WORK/build
[[ "$?" != "0" ]] && die "Build failed"

echo "Tag & Commit"
echo "Current Version $(xcrun agvtool what-version -terse)"
xcrun agvtool next-version
VERSION="v1.$(xcrun agvtool what-version -terse)"
echo "New Version $VERSION"
git commit -am"Version $VERSION"
git tag $VERSION
git push origin HEAD
git push --tags

APP=$(find $WORK -name 'Wallpaper Manager.app')
pushd "$(dirname "$APP")"
zip -r  "$WORK/wallman-${VERSION}.zip" "$(basename "$APP")"
popd

echo $WORK

ls -l $WORK
open $WORK
