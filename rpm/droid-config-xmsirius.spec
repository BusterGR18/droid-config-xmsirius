# These and other macros are documented in ../droid-configs-device/droid-configs.inc
# Feel free to cleanup this file by removing comments, once you have memorised them ;)

%define device xmsirius
%define vendor xiaomi

%define vendor_pretty Xiaomi
%define device_pretty Mi 8 SE

# Community HW adaptations need this
%define community_adaptation 1

# Pixel ratio 1.0 was originally jolla phone with 245ppi, and the devices
# should roughly have their ppi compared to that. Large displays can use
# bigger ratio if seen fit. Values are with 0.25 increments.
%define pixel_ratio 1.0


%define android_version_major 13

# Device-specific ofono configuration
Provides: ofono-configs
Obsoletes: ofono-configs-mer
Obsoletes: ofono-configs-binder

# Patched Android service managers (sparse/usr/libexec/droid-sm-patch) link
# against bionic/Android libs from /system; don't generate RPM requires for them.
%global __requires_exclude_from ^/usr/libexec/droid-sm-patch/.*$
%global __provides_exclude_from ^/usr/libexec/droid-sm-patch/.*$

%include droid-configs-device/droid-configs.inc
%include patterns/patterns-sailfish-device-adaptation-xmsirius.inc
%include patterns/patterns-sailfish-device-configuration-xmsirius.inc

# IMPORTANT if you want to comment out any macros in your .spec, delete the %
# sign, otherwise they will remain defined! E.g.:
#define some_macro "I'll not be defined because I don't have % in front"

