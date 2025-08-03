#!/bin/sh

#  ci_post_xcodebuild.sh
#  STATS
#
#  Created by Jerónimo Cabezuelo Ruiz on 18/2/24.
#  

set -e # fails build if any command fails

if [[ -n $CI_APP_STORE_SIGNED_APP_PATH ]]; # checks if there is an AppStore signed archive after running xcodebuild
then
    TESTFLIGHT_DIR_PATH=../TestFlight
    mkdir $TESTFLIGHT_DIR_PATH
    git fetch --deepen 100
    git log $(git describe --tags --abbrev=0)..HEAD --pretty=format:"%s" | cat > $TESTFLIGHT_DIR_PATH/WhatToTest.en-US.txt
    git log $(git describe --tags --abbrev=0)..HEAD --pretty=format:"%s" | cat > $TESTFLIGHT_DIR_PATH/WhatToTest.es-ES.txt

    BUILD_TAG=${CI_BUILD_NUMBER}
    VERSION=$(cat ../${CI_PRODUCT}.xcodeproj/project.pbxproj | grep -m1 'MARKETING_VERSION' | cut -d'=' -f2 | tr -d ';' | tr -d ' ')

    TAG="${CI_PRODUCT}/Release/${VERSION}/${BUILD_TAG}"

    if git rev-parse "$TAG" >/dev/null 2>&1; then
        echo "Tag $TAG already exists. Skipping tag creation."
    else
        git tag "$TAG"
        git push --tags https://${GIT_AUTH}@github.com/${REPO_PATH}.git
    fi

fi
