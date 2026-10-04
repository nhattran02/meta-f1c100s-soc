SUMMARY = "U-Boot 2018.01 for Allwinner F1C100s"

require recipes-bsp/u-boot/u-boot.inc

LICENSE = "GPL-2.0-or-later"
LIC_FILES_CHKSUM = "file://Licenses/README;md5=a2c678cfd4a4d97135585cad908541c6"

DEPENDS += "bc-native dtc-native swig-native python3-native"

COMPATIBLE_MACHINE = "^f1c100s-soc$"

SRC_URI = "git://github.com/ninhnn2/u-boot-f1c100s.git;protocol=https;branch=master \
           file://boot.cmd \
          "
SRCREV = "c7d60a02f3d14cad95a8c3e782315dc71892882e"

S = "${WORKDIR}/git"

UBOOT_ENV = "boot"
UBOOT_ENV_SUFFIX = "scr"

EXTRA_OEMAKE += 'HOSTLDSHARED="${BUILD_CC} -shared ${BUILD_LDFLAGS} ${BUILD_CFLAGS}"'
