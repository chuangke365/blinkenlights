#!/bin/sh
dot_version=`grep DEMO_VERSION config.py | sed -e 's/DEMO_VERSION = "\(.*\)"/\1/'`
underscore_version=`printf %s $dot_version | sed -e 's/\./_/g'`
dmg=starter_kit_blinkenlights_demo_macos_$underscore_version.dmg
rm $dmg
hdiutil create -fs HFS+ -volname "Starter-Kit-Blinkenlights-Demo-$dot_version" -srcfolder dist $dmg
