#!/bin/sh
# Called by bluebinder_post.sh (bluebinder package) to provide
# /var/lib/bluetooth/board-address. xmsirius sets none of ro.bt.bdaddr_path,
# ro.vendor.bt.bdaddr_path or persist.vendor.service.bdroid.bdaddr; the qcom BT
# HAL loads the address from NV into the controller instead. Once bluebinder
# has brought up the vhci controller, the kernel knows that public address, so
# copy it from debugfs. If it can't be found, write nothing: bluebinder_post.sh
# then reports the failure instead of us inventing an address.
OUT=/var/lib/bluetooth/board-address
[ -f "$OUT" ] && exit 0

i=0
while [ $i -lt 40 ]; do
    for f in /sys/kernel/debug/bluetooth/hci*/identity; do
        [ -r "$f" ] || continue
        addr=$(cut -d' ' -f1 "$f")
        case "$addr" in
            ""|00:00:00:00:00:00) ;;
            ??:??:??:??:??:??)
                mkdir -p /var/lib/bluetooth
                echo "$addr" > "$OUT"
                exit 0
                ;;
        esac
    done
    sleep 0.5
    i=$((i + 1))
done
echo "droid-get-bt-address: no controller address found in debugfs" >&2
exit 0
