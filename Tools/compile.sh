#!/bin/bash
set -xe
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR/..

set -o pipefail

cd submodules/HockeySDK-Mac
bundle install
cd Support

HOCKEYSDK_FRAMEWORK_PATH="$(xcodebuild -project HockeySDK.xcodeproj -scheme HockeySDK -configuration Release -destination 'platform=OS X' clean > /dev/null 2>&1 && xcodebuild -project HockeySDK.xcodeproj -scheme HockeySDK -configuration Release -destination 'platform=OS X' | grep touch  |awk '{print $3}')"

cd $DIR/..

if [ -d "$HOCKEYSDK_FRAMEWORK_PATH" ] ; then
  echo "Found a build result from the HockeySDK-Mac compile"

  if [ -d HockeySDK.framework ] ; then
    echo "Remove the existing HockeySDK.framework in this tree"
    rm -fr HockeySDK.framework
  fi

  echo "Symlink the framework from the build into this tree"
  ln -sf "$HOCKEYSDK_FRAMEWORK_PATH" HockeySDK.framework
else
  echo "Could not find HockeySDK-Mac framework build asset path"
  ls -la "$HOCKEYSDK_FRAMEWORK_PATH"
fi

ls -la

exit 0

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

