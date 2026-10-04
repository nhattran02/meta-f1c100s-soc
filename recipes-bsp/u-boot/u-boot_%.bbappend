FILESEXTRAPATHS:prepend:f1c100s-soc := "${THISDIR}/files:"

SRC_URI:append:f1c100s-soc = " file://boot.cmd"

UBOOT_ENV:f1c100s-soc = "boot"
UBOOT_ENV_SUFFIX:f1c100s-soc = "scr"
