FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://0001-config-and-dts.patch \
            file://0002-mcu-watchdog.patch \
            file://0003-fec-clock.patch \
            file://0004-rtl8211f.patch \
            file://0005-mcu-reboot.patch \
            file://0006-io-reset.patch \
            file://0001-enable-pci-controller.patch \
            file://0001-fix-mcu-reboot-unstable.patch \
            "
LOCALVERSION = ""
