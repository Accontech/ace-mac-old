#!/bin/bash
set -xe
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR/..

set -o pipefail

cd submodules/HockeyApp-Mac
bundle install
cd Support
HOCKEYSDK_FRAMEWORK_PATH=$(xcodebuild -project HockeySDK.xcodeproj -scheme "HockeySDK" -configuration Release -destination "platform=OS X" clean && xcodebuild -project HockeySDK.xcodeproj -scheme "HockeySDK" -configuration Release -destination "platform=OS X" | grep touch  |awk '{print $3}')

cd $DIR/..

if [ -d "$HOCKEYSDK_FRAMEWORK_PATH" ] ; then
  if [ -d HockeySDK.framework ] ; then
    rm -fr HockeySDK.framework
  fi

  ln -sf "$HOCKEYSDK_FRAMEWORK_PATH" HockeySDK.framework
fi

make -j 8
ninja -C WORK/cmake
wget http://ciscobinary.openh264.org/libopenh264-1.5.0-osx64.dylib.bz2 
bzip2 -d libopenh264-1.5.0-osx64.dylib.bz2
install_name_tool -id @rpath/libopenh264.1.dylib libopenh264-1.5.0-osx64.dylib 
mv -f  libopenh264-1.5.0-osx64.dylib  WORK/Build/linphone_package/linphone-sdk-tmp/lib/libopenh264.1.dylib 

xcodebuild -project ACE.xcodeproj -alltargets -parallelizeTargets -configuration \
 Debug build CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" CODE_SIGN_ENTITLEMENTS="" 

xcodebuild -project ACE.xcodeproj -alltargets -parallelizeTargets -configuration \
 Release build CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" CODE_SIGN_ENTITLEMENTS="" 

