#!/bin/bash

echo "🏛 Archiving FiskalySDK..."
#iOS device
echo "🏛 ...iphone device"
xcodebuild archive -scheme FiskalySDK -archivePath "./build/ios.xcarchive" -sdk iphoneos SKIP_INSTALL=NO

#iOS simulator
echo "🏛 ...iphone simulator"
xcodebuild archive -scheme FiskalySDK -archivePath "./build/ios_sim.xcarchive" -sdk iphonesimulator SKIP_INSTALL=NO

xcodebuild -create-xcframework \
    -framework "./build/ios.xcarchive/Products/Library/Frameworks/FiskalySDK.framework" \
    -framework "./build/ios_sim.xcarchive/Products/Library/Frameworks/FiskalySDK.framework" \
    -output "./build/FiskalySDK.xcframework"

#TODO: Compress this file like generateFramework.sh, but we need to generate the checksum make the modification in Package.swift
cp -r ./build/FiskalySDK.xcframework ./

#cleanup
rm -rf build/
