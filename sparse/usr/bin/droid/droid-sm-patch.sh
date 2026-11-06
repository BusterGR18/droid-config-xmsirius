#!/bin/sh
# Bind-mount hybris-built Android components over the stock ones on /system
# and /vendor before Android init starts. The system partition on xmsirius is
# a stock LineageOS build, not built from the hybris tree, so:
#
# - servicemanager/vndservicemanager abort in android::Access::Access() and
#   hwservicemanager in AccessControl when SELinux is off (selinuxfs is not
#   mounted on Sailfish OS); use builds patched to allow all requests then.
# - its com.android.runtime APEX has unpatched bionic, while libhybris uses
#   the hybris-patched bionic from /usr/libexec/droid-hybris. HALs loaded
#   in-process through libhybris (e.g. audio.primary in PulseAudio) then end
#   up with two bionics and crash. Use the runtime APEX from the hybris build
#   so apexd mounts matching bionic/linker.
#
# Temporary until these come from a system image built from the hybris tree;
# run from droid-hal-init.service ExecStartPre so it adds no new unit
# ordering. Already-mounted paths are skipped so service restarts don't stack
# binds.
SRC=/usr/libexec/droid-sm-patch

bind_one() {
    src="$SRC/$1"
    dst="$2"
    [ -e "$src" ] && [ -e "$dst" ] || return 0
    grep -q " $dst " /proc/mounts || mount --bind "$src" "$dst"
}

bind_one servicemanager           /system/bin/servicemanager
bind_one hwservicemanager         /system/bin/hwservicemanager
bind_one vndservicemanager        /vendor/bin/vndservicemanager
bind_one com.android.runtime.apex /system/apex/com.android.runtime.apex
exit 0
