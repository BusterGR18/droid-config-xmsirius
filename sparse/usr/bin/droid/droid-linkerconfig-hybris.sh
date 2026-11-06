#!/bin/sh
# Map /usr/libexec/droid-hybris/system/bin to the "system" section of the
# generated Android linker config. Android's linkerconfig only knows the stock
# binary directories, so droidmedia's minimediaservice/minisfservice ran in a
# fallback namespace without APEX libraries and crash-looped ("CANNOT LINK ...
# libandroidicu.so"), which breaks the camera and can leave gst-droid users
# such as ngfd hanging in GStreamer init.
#
# Android init (re)generates /linkerconfig/ld.config.txt several times during
# boot, the last time on a freshly mounted tmpfs after APEX activation, so a
# single edit or an inotify watch gets lost. Check every 2 s for 3 minutes
# after droid-hal-init and add the line whenever a full (post-APEX) config is
# missing it. init restarts the crash-looping services by itself.
F=/linkerconfig/ld.config.txt
LINE='dir.system = /usr/libexec/droid-hybris/system/bin/'

i=0
while [ $i -lt 90 ]; do
    if [ -f "$F" ] && grep -q "com_android_i18n" "$F" && ! grep -qxF "$LINE" "$F"; then
        sed -i "1i $LINE" "$F"
    fi
    sleep 2
    i=$((i + 1))
done
exit 0
