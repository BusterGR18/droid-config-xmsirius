#!/bin/sh
# Turn on the built-in qcacld WLAN driver. On Android the WiFi HAL does this
# (WIFI_DRIVER_STATE_CTRL_PARAM=/dev/wlan, WIFI_DRIVER_STATE_ON=ON); on Sailfish
# nothing does, so wlan0 never appears. The driver only creates its interfaces
# once icnss has the WLAN firmware (after pd-mapper/pm-service are up), so retry
# until wlan0 shows up.
i=0
while [ $i -lt 30 ]; do
    if [ -e /sys/class/net/wlan0 ]; then
        exit 0
    fi
    [ -w /dev/wlan ] && echo ON > /dev/wlan
    sleep 2
    i=$((i + 1))
done
echo "droid-wlan-enable: wlan0 did not appear" >&2
exit 1
