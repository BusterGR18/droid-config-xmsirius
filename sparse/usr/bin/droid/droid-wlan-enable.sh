#!/bin/sh
# Turn on the built-in qcacld WLAN driver. On Android the WiFi HAL does this
# (WIFI_DRIVER_STATE_CTRL_PARAM=/dev/wlan, WIFI_DRIVER_STATE_ON=ON); on Sailfish
# nothing does, so wlan0 never appears. The driver only creates its interfaces
# once icnss has the WLAN firmware (after pd-mapper/pm-service are up), so retry
# until wlan0 shows up.
#
# The vendor WCNSS_qcom_cfg.ini sets gEnableConcurrentSTA=wlan1, so the driver
# also creates a second station interface. Android leaves it idle; connman
# scans on it too, so every network was listed twice. Delete it.
i=0
while [ ! -e /sys/class/net/wlan0 ]; do
    if [ $i -ge 30 ]; then
        echo "droid-wlan-enable: wlan0 did not appear" >&2
        exit 1
    fi
    [ -w /dev/wlan ] && echo ON > /dev/wlan
    sleep 2
    i=$((i + 1))
done

# wlan1 is created together with wlan0; give it a moment if it lags behind.
j=0
while [ $j -lt 5 ] && [ ! -e /sys/class/net/wlan1 ]; do
    sleep 1
    j=$((j + 1))
done
if [ -e /sys/class/net/wlan1 ]; then
    iw dev wlan1 del || echo "droid-wlan-enable: could not delete wlan1" >&2
fi
exit 0
