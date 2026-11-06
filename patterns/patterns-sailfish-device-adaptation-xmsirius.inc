# Feel free to disable non-critical HA parts during devel by commenting lines out
# Generated in hadk by executing: rpm/dhd/helpers/add_new_device.sh

%package -n patterns-sailfish-device-adaptation-xmsirius
Summary: Jolla HW Adaptation xmsirius
Requires: droid-hal-xmsirius
Requires: droid-hal-xmsirius-img-boot
Requires: droid-hal-xmsirius-kernel-modules
Requires: droid-config-xmsirius-sailfish
Requires: droid-config-xmsirius-pulseaudio-settings
Requires: droid-config-xmsirius-policy-settings
Requires: droid-config-xmsirius-preinit-plugin
Requires: droid-config-xmsirius-flashing
Requires: droid-config-xmsirius-bluez5
Requires: droid-hal-version-xmsirius

# dmsetup for droid-lp-setup.sh (maps Android dynamic partitions)
Requires: device-mapper

# Hybris packages
Requires: libhybris-libEGL
Requires: libhybris-libGLESv2
Requires: libhybris-libwayland-egl

# Sensors
Requires: hybris-libsensorfw-qt5

# Vibra
Requires: ngfd-plugin-native-vibrator
Requires: libngf-qt5-qtfeedback

# Needed for /dev/touchscreen symlink
Requires: qt5-plugin-generic-evdev

Requires: pulseaudio-modules-droid
Requires: pulseaudio-modules-droid-hidl

# The -dummy-af is needed for newer devices that run the main
# audiosystem-passthrough in qti mode (e.g. >=Android 9 Qualcomm),
# to fix non-responding Camera app and/or voice during a phone call:
#Requires: audiosystem-passthrough-dummy-af

# for audio recording to work:
Requires: qt5-qtmultimedia-plugin-mediaservice-gstmediacapture

# These need to be per-device due to differing backends (fbdev, eglfs, hwc, ..?)
Requires: qt5-qtwayland-wayland_egl
Requires: qt5-qpa-hwcomposer-plugin
Requires: qtscenegraph-adaptation

# For hybris devices with droidmedia, see HADK pdf for more information
Requires: gstreamer1.0-droid
Obsoletes: gmp-droid

# This is needed for notification LEDs
Requires: mce-plugin-libhybris

# USB mode controller
Requires: usb-moded

# hammerhead, grouper, and maguro use this in scripts, so include for all
Requires: rfkill

# Telephony: ofono plugin for the Android radio HAL (qcrild, radio@1.x HIDL);
# configured by /etc/ofono/binder.conf
Requires: ofono-binder-plugin

# Bluetooth: bridges the Android Bluetooth HAL to a virtual hci for bluez5
Requires: bluebinder

# enable device lock and allow to select untrusted software
Requires: jolla-devicelock-daemon-encsfa

# Enable home encryption
#Requires: sailfish-device-encryption

# For GPS
Requires: geoclue-provider-hybris

# For FM radio on some QCOM devices
#Requires: qt5-qtmultimedia-plugin-mediaservice-irisradio
#Requires: jolla-mediaplayer-radio

# NFC support
# 1. binder plugin requires Android 8 or a newer base
# 2. pn54x plugin talks directly to pn54x driver
# These plugins are mutually exclusive, you need to pick one:
#Requires: nfcd-binder-plugin
#Requires: nfcd-pn54x-plugin

%description -n patterns-sailfish-device-adaptation-xmsirius
Pattern with packages for xmsirius HW Adaptation

%files -n patterns-sailfish-device-adaptation-xmsirius
