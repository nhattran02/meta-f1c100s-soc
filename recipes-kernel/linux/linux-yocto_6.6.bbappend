FILESEXTRAPATHS:prepend:f1c100s-soc := "${THISDIR}/files:"

COMPATIBLE_MACHINE:f1c100s-soc = "^f1c100s-soc$"
KBRANCH:f1c100s-soc = "v6.6/standard/base"

# No BSP in yocto-kernel-cache: the in-layer defconfig is the whole config
SRC_URI:append:f1c100s-soc = " file://defconfig"
KCONFIG_MODE:f1c100s-soc = "alldefconfig"

# Keep the kernel lean: drop distro debug/netfilter/ptest fragments
KERNEL_FEATURES:remove:f1c100s-soc = " \
    features/netfilter/netfilter.scc \
    features/debug/debug-kernel.scc \
    features/scsi/scsi-debug.scc \
    features/nf_tables/nft_test.scc \
    features/gpio/mockup.scc \
    features/gpio/sim.scc \
    features/net/team/team.scc \
"
