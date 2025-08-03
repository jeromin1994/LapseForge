#!/bin/sh

#  ci_post_clone.sh
#  STATS
#
#  Created by Jerónimo Cabezuelo Ruiz on 5/1/24.
#  

defaults write com.apple.dt.Xcode IDESkipPackagePluginFingerprintValidatation -bool YES
defaults write com.apple.dt.Xcode IDESkipMacroFingerprintValidation -bool YES
