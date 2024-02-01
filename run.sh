#!/bin/bash -e

#
# TIM-Referenzumgebung
# Copyright (C) 2024 - akquinet GmbH
#
# This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License.
#
# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

# copy from confluence
export $(grep -v '^#' local.properties | xargs)

goal_android() {
  flutter build apk --debug --dart-define=ENABLE_DEBUG_WIDGET=true --dart-define=ENABLE_TEST_DRIVER=true --dart-define=DEBUG_WIDGET_VISIBLE=false --dart-define=TOKEN_DISPENSER_USER=${TOKEN_DISPENSER_USER} --dart-define=TOKEN_DISPENSER_PASSWORD=${TOKEN_DISPENSER_PASSWORD} --dart-define=TOKEN_DISPENSER_URL=https://timref-auth.eu.timref.akquinet.nx2.dev:8448/2/dispenseToken

  cp build/app/outputs/flutter-apk/app-debug.apk .
}

export ANDROID_HOME=~/Library/Android/sdk
export PATH=$ANDROID_HOME/platform-tools:$PATH
ADB=$ANDROID_HOME/platform-tools/adb

goal_devices() {
  $ADB devices
}

goal_clean(){
  set +e
  $ADB -s emulator-5554 uninstall io.appium.uiautomator2.server
  $ADB -s emulator-5554 uninstall io.appium.uiautomator2.server.test
  $ADB -s emulator-5556 uninstall io.appium.uiautomator2.server
  $ADB -s emulator-5556 uninstall io.appium.uiautomator2.server.test
  $ADB -s emulator-5558 uninstall io.appium.uiautomator2.server
  $ADB -s emulator-5558 uninstall io.appium.uiautomator2.server.test

  $ADB -s emulator-5554 uninstall  de.akquinet.timref.messengerclient
  $ADB -s emulator-5556 uninstall  de.akquinet.timref.messengerclient
  $ADB -s emulator-5558 uninstall  de.akquinet.timref.messengerclient

  set -e
}


goal_appium1() {
  goal_clean
  appium server -p 9010 -a 127.0.0.1 -pa /wd/hub --allow-insecure=adb_shell --relaxed-security
}

goal_appium2() {
  goal_clean
  appium server -p 9011 -a 127.0.0.1 -pa /wd/hub --allow-insecure=adb_shell --relaxed-security
}

goal_appium3() {
  goal_clean
  appium server -p 9012 -a 127.0.0.1 -pa /wd/hub --allow-insecure=adb_shell --relaxed-security
}

goal_buildAndRun1() {
  goal_android
  goal_appium1
}

goal_web() {
  flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8989
}

goal_start_proxy() {
  docker-compose up --build proxy
}

goal_test_proxy() {
  set +e
  docker-compose up --build --abort-on-container-exit
  result=$?
  set -e

  docker-compose rm -f

  if [ $result != 0 ]; then
    echo "At least one test failed!"
    exit 1
  fi
}

goal_help() {
  echo "usage: $0 <goal>
    available goals

    Local:
    ------
    android            - Build the flutter android app
    appium1            - Start Appium 1 on port 9010
    buildAndRun1       - Build APK and start Appium 1 on port 9010
    appium2            - Start Appium 2 on port 9011
    appium3            - Start Appium 3 on port 9012
    clean              - Uninstall UiAutomator and TI-Messenger Client
    web                - Launch browser version

    Proxy:
    ------
    start_proxy        - Run docker hba auth proxy
    test_proxy         - Run tests against hba auth proxy
    "
  exit 1
}

main() {
  local TARGET=${1:-}
  if [ -n "${TARGET}" ] && type -t "goal_$TARGET" &>/dev/null; then
    "goal_$TARGET" "${@:2}"
  else
    goal_help
  fi
}

main "$@"
