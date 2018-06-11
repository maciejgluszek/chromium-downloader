#!/bin/sh
#
# Google Chromium Downloader/Installer
#
#
# Author: Maciej Głuszek <maciej.gluszek@gmail.com>
#
# https://github.com/maciejgluszek/chromium-downloader
#
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; version 2
# of the License.
#
# Usage:
#
# For details please check README file
#
# Running the script without parameters checks for new snapshots, downloads and installs the package
#
# --check [Checks for new available snapshots without downloading an archive]
#
# --create-desktop-file [Creates chromium.desktop file with parameters specified by the user in the script. .desktop files are placed in ~/.local/share/applications directory]
#

# URL with latest commit
CONFIG_URL_CHROMIUM_LATEST_COMMIT="https://www.googleapis.com/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2FLAST_CHANGE"

# URL with latest chromium archive
CONFIG_URL_CHROMIUM_DOWNLOAD="https://www.googleapis.com/storage/v1/b/chromium-browser-snapshots/o?delimiter=/&prefix=Linux_x64/"

# Directory where Chromium is located
CONFIG_CHROMIUM_DIRECTORY="/opt/google-chromium"

# We need a subdirectory named "app" inside "google-chromium" because of latest commit file location
CONFIG_CHROMIUM_APP_DIRECTORY="/app"

# Last used commit file location
CONFIG_CHROMIUM_LAST_USED_COMMIT_FILE="/opt/google-chromium/chromium-last-commit.txt"

# Temporary location used to download and unzip Chromium archive
CONFIG_CHROMIUM_TMP="/tmp/chromium-tmp"

# Profile directory location
# Should be specified as a separate directory from default Chrome stable instalation
CONFIG_CHROMIUM_PROFILE_LOCATION="/home/maciek/.config/google-chromium"

# Wget location
CONFIG_WGET_LOCATION="/usr/bin/wget"


# Check if last used commit file exists
check_if_last_used_commit_file_exists() {
  if [ ! -e $CONFIG_CHROMIUM_LAST_USED_COMMIT_FILE ]; then
    echo "CANNOT FIND LAST COMMIT FILE - "$CONFIG_CHROMIUM_LAST_USED_COMMIT_FILE". EXITING"

    exit 1
  fi
}

# Check if Wget exists
check_if_wget_exists() {
  if [ ! -x $CONFIG_WGET_LOCATION ]; then
    echo "CANNOT FIND WGET. PLEASE INSTALL WGET OR SET IT IN YOUR PATH. EXITING"

    exit 1
  fi
}

# Create .desktop file
create_desktop_file() {
  `cp chromium.desktop.example chromium.desktop`

  `sed -i "s@CHROMIUM_ICON@$CONFIG_CHROMIUM_DIRECTORY$CONFIG_CHROMIUM_APP_DIRECTORY\/product_logo_48.png@" chromium.desktop`

  `sed -i "s@CHROMIUM_EXEC@$CONFIG_CHROMIUM_DIRECTORY$CONFIG_CHROMIUM_APP_DIRECTORY\/chrome-wrapper --user-data-dir=$CONFIG_CHROMIUM_PROFILE_LOCATION@" chromium.desktop`

  echo "CHANGES WRITTEN TO chromium.desktop file"

  exit 0
}

# Check for parameters
while [ $# > 0 ]
  do
    key="$1"

    case $key in
      --check)

      check_if_last_used_commit_file_exists

      check_if_wget_exists

      # Read latest commit ID used
      CHROMIUM_CURRENT_COMMIT_ID=`cat $CONFIG_CHROMIUM_LAST_USED_COMMIT_FILE`

      # Fetch latest commit ID
      CHROMIUM_LATEST_COMMIT_TMP=$($CONFIG_WGET_LOCATION --no-cache $CONFIG_URL_CHROMIUM_LATEST_COMMIT -q -O chromium-last-commit.txt)
      CHROMIUM_LATEST_COMMIT=`grep -Po '"cr-commit-position-number": "[0-9]+?"' chromium-last-commit.txt | sed 's/\"//g' | awk '{print $2}'`

      # Remove temporary file
      rm chromium-last-commit.txt

      # Check if we're using the latest snapshot
      if [ $CHROMIUM_LATEST_COMMIT -gt $CHROMIUM_CURRENT_COMMIT_ID ]; then
        echo "NEW COMMIT AVAILABLE - $CHROMIUM_LATEST_COMMIT (USING COMMIT ID - $CHROMIUM_CURRENT_COMMIT_ID)"
        exit 0
      else
        echo "USING LATEST CHROMIUM BUILD - COMMIT ID $CHROMIUM_CURRENT_COMMIT_ID"
        exit 0
      fi
      shift
      ;;
      --create-desktop-file)
        create_desktop_file
      exit 0
      shift
      ;;
      *)
      break
     ;;
    esac
  done

#Check
check_if_last_used_commit_file_exists

#Check
check_if_wget_exists

# Check if Chromium location directory exists
if [ ! -d $CONFIG_CHROMIUM_DIRECTORY ]; then
  mkdir $CONFIG_CHROMIUM_DIRECTORY
  mkdir $CONFIG_CHROMIUM_DIRECTORY$CONFIG_CHROMIUM_APP_DIRECTORY
fi

# Check if temporary dirextory exists and if is writable
if [ ! -d $CONFIG_CHROMIUM_TMP ]; then
  mkdir $CONFIG_CHROMIUM_TMP

  else if [ ! -w $CONFIG_CHROMIUM_TMP ]; then
    echo "TEMP DIRECTORY - "$CONFIG_CHROMIUM_TMP" IS NOT WRITABLE. EXITING"
    exit 1
  fi
fi

# Switch to temporary working directory
cd $CONFIG_CHROMIUM_TMP

# Read latest commit ID used
CHROMIUM_CURRENT_COMMIT_ID=`cat $CONFIG_CHROMIUM_LAST_USED_COMMIT_FILE`

# Fetch latest commit ID
CHROMIUM_LATEST_COMMIT_TMP=$($CONFIG_WGET_LOCATION --no-cache $CONFIG_URL_CHROMIUM_LATEST_COMMIT -q -O chromium-last-commit.txt)
CHROMIUM_LATEST_COMMIT=`grep -Po '"cr-commit-position-number": "[0-9]+?"' chromium-last-commit.txt | sed 's/\"//g' | awk '{print $2}'`

# Check if we're using the latest snapshot
if [ $CHROMIUM_LATEST_COMMIT -gt $CHROMIUM_CURRENT_COMMIT_ID ]; then

  # Check if we have a commit ID
  if [ $CHROMIUM_LATEST_COMMIT -gt 0 -a $CHROMIUM_LATEST_COMMIT -eq $CHROMIUM_LATEST_COMMIT 2> /dev/null ]; then

    # Download lateest Chromium archive
    CHROME_DOWNLOAD_LOCATION_TMP=`$CONFIG_WGET_LOCATION --no-cache "$CONFIG_URL_CHROMIUM_DOWNLOAD$CHROMIUM_LATEST_COMMIT/" -q -O chromium-download-locations.txt`
    CHROME_DOWNLOAD_LOCATION=`grep -Po '"mediaLink": ".+?chrome-linux.zip.+?"' chromium-download-locations.txt | sed 's/\"//g' | awk '{print $2}'`
    $CONFIG_WGET_LOCATION --no-cache "$CHROME_DOWNLOAD_LOCATION" -O chrome-linux.zip

    # Archive downloaded, proceed
    if [ -f $CONFIG_CHROMIUM_TMP/chrome-linux.zip ]; then

      # Remove previous Chromium installation
      rm -rf $CONFIG_CHROMIUM_DIRECTORY$CONFIG_CHROMIUM_APP_DIRECTORY/*

      #Unpack archive
      unzip ./chrome-linux.zip

      # Copy new files
      cp -rp chrome-linux/* $CONFIG_CHROMIUM_DIRECTORY$CONFIG_CHROMIUM_APP_DIRECTORY/
      cd
      rm -rf $CONFIG_CHROMIUM_TMP

      # Update latest commit ID file
      echo -n $CHROMIUM_LATEST_COMMIT > $CONFIG_CHROMIUM_LAST_USED_COMMIT_FILE

      # Fix sandbox SUID - https://chromium.googlesource.com/chromium/src/+/lkcr/docs/linux_suid_sandbox_development.md
      cd $CONFIG_CHROMIUM_DIRECTORY$CONFIG_CHROMIUM_APP_DIRECTORY
      sudo sh -c "mv chrome_sandbox chrome-sandbox; chown root chrome-sandbox; chmod 4755 chrome-sandbox"

      exit 0
    else
      echo "CHROMIUM ARCHIVE NOT FOUND. EXITING"
      exit 1
    fi
  fi
else echo "USING LATEST CHROMIUM BUILD - COMMIT ID $CHROMIUM_CURRENT_COMMIT_ID. EXITING"
  exit 0
fi
