#!/bin/sh
# Bind-mount service managers patched to tolerate SELinux being unavailable
# (selinuxfs is not mounted on Sailfish OS) over the stock Android binaries.
# Stock servicemanager/vndservicemanager abort in android::Access::Access()
# and hwservicemanager in AccessControl when SELinux is off.
#
# Temporary until the patch is in the system image; run from
# droid-hal-init.service ExecStartPre so it adds no new unit ordering.
# Already-mounted paths are skipped so service restarts don't stack binds.
SRC=/usr/libexec/droid-sm-patch
for p in /system/bin/servicemanager /system/bin/hwservicemanager /vendor/bin/vndservicemanager; do
    b="$SRC/$(basename "$p")"
    [ -x "$b" ] && [ -e "$p" ] || continue
    grep -q " $p " /proc/mounts || mount --bind "$b" "$p"
done
exit 0
