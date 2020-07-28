#!/bin/bash

PROJECT_NAME=FiskalySDK
BUILD_DIR=${PWD}/Build
IOS_DIR=${BUILD_DIR}/iOS
SIMULATOR_DIR=${BUILD_DIR}/Simulator
UNIVERSAL_OUTPUT_DIR=${PWD}/fiskaly-sdk-universal
RELEASE_DIR=${PWD}/Build/FiskalySDK.framework

# make sure the output directory exists
mkdir -p "${UNIVERSAL_OUTPUT_DIR}"

# Step 1. Build Device and Simulator versions
xcodebuild clean build -project FiskalySDK.xcodeproj -scheme FiskalySDK -configuration Release -destination generic/platform=iOS CONFIGURATION_BUILD_DIR=${IOS_DIR}
xcodebuild clean build -project FiskalySDK.xcodeproj -scheme FiskalySDK -configuration Release -destination generic/platform='iOS Simulator' CONFIGURATION_BUILD_DIR=${SIMULATOR_DIR}

# Step 2. Copy the framework structure (from iphoneos build) to the universal folder
cp -R "${IOS_DIR}/${PROJECT_NAME}.framework" "${UNIVERSAL_OUTPUT_DIR}/"

# Step 3. Copy Swift modules from iphonesimulator build (if it exists) to the copied framework directory
SIMULATOR_SWIFT_MODULES_DIR="${SIMULATOR_DIR}/${PROJECT_NAME}.framework/Modules/${PROJECT_NAME}.swiftmodule/"
echo ${SIMULATOR_SWIFT_MODULES_DIR}
if [ -d "${SIMULATOR_SWIFT_MODULES_DIR}" ]; then
    cp -R "${SIMULATOR_SWIFT_MODULES_DIR}." "${UNIVERSAL_OUTPUT_DIR}/${PROJECT_NAME}.framework/Modules/${PROJECT_NAME}.swiftmodule"
fi

# Step 4. Create universal binary file using lipo and place the combined executable in the copied framework directory
lipo -create -output "${UNIVERSAL_OUTPUT_DIR}/${PROJECT_NAME}.framework/${PROJECT_NAME}" "${SIMULATOR_DIR}/${PROJECT_NAME}.framework/${PROJECT_NAME}" "${IOS_DIR}/${PROJECT_NAME}.framework/${PROJECT_NAME}"

# Step 5. Create ZIP File with License and Fat Framework
cp license.txt ${UNIVERSAL_OUTPUT_DIR}
cd ${UNIVERSAL_OUTPUT_DIR}
zip -r FiskalySDK.zip FiskalySDK.framework license.txt
cp FiskalySDK.zip ../
cd ../

# cleanup
rm -rf Build
rm -rf ${UNIVERSAL_OUTPUT_DIR}