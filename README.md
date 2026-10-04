# meta-f1c100s-soc

**Yocto Project BSP layer for the Allwinner F1C100s SoC**

![Yocto](https://img.shields.io/badge/Yocto-scarthgap%20(5.0)-blue)
![Kernel](https://img.shields.io/badge/Linux-6.6%20(linux--yocto)-orange)
![Arch](https://img.shields.io/badge/Arch-ARM926EJ--S%20(ARMv5TE)-green)
![License](https://img.shields.io/badge/License-MIT-lightgrey)

---

## Table of Contents

- [Overview](#overview)
- [Supported Hardware](#supported-hardware)
- [Software Components](#software-components)
- [Layer Dependencies](#layer-dependencies)
- [Layer Structure](#layer-structure)
- [Quick Start](#quick-start)
- [Build Artifacts](#build-artifacts)
- [SD Card Layout](#sd-card-layout)
- [Flashing the Image](#flashing-the-image)
- [Booting](#booting)
- [Kernel Configuration](#kernel-configuration)
- [Contributing](#contributing)
- [Maintainer](#maintainer)
- [License](#license)

---

## Overview

`meta-f1c100s-soc` provides Board Support Package (BSP) support for the
**Allwinner F1C100s** (`suniv` family), a low-cost ARM9 SoC with 32 MB of
embedded DDR1 memory.

The layer provides:

- Machine configuration `f1c100s-soc` (ARM926EJ-S tune)
- U-Boot integration with SPL (`u-boot-sunxi-with-spl.bin`) and a boot script
- Linux kernel support based on `linux-yocto` 6.6 with a minimal in-layer defconfig
- Bootable SD card image generation (WIC + bmap)

This layer is compatible with **Yocto Project scarthgap (5.0 LTS)**.

---

## Supported Hardware

| SoC               | CPU core     | RAM              |
|-------------------|--------------|------------------|
| Allwinner F1C100s | ARM926EJ-S   | 32 MB DDR1 (SiP) |

### Supported Machines

| `MACHINE`     | Reference board | Device Tree                               | U-Boot defconfig           |
|---------------|-----------------|-------------------------------------------|----------------------------|
| `f1c100s-soc` | Lichee Pi Nano  | `allwinner/suniv-f1c100s-licheepi-nano.dtb` | `licheepi_nano_defconfig` |


## Software Components

| Component      | Recipe                        | Version / Branch           |
|----------------|-------------------------------|----------------------------|
| Linux kernel   | `linux-yocto` (bbappend)      | 6.6 — `v6.6/standard/base` |
| Bootloader     | `u-boot` (bbappend)           | provided by poky           |
| Toolchain      | GCC                           | provided by poky           |
---

## Layer Structure

```
meta-f1c100s-soc/
├── conf/
│   ├── layer.conf
│   └── machine/
│       └── f1c100s-soc.conf
├── recipes-bsp/
│   └── u-boot/
│       ├── files/
│       │   └── boot.cmd
│       ├── u-boot-f1c100s_2018.01.bb
│       └── u-boot_%.bbappend
├── recipes-kernel/
│   └── linux/
│       ├── files/
│       │   └── defconfig
│       └── linux-yocto_6.6.bbappend
├── wic/
│   └── f1c100s-sdcard.wks
├── COPYING.MIT
└── README.md
```

---

## Quick Start

### 1. Prepare the host

A supported Linux distribution is required (Ubuntu 22.04 / 24.04 recommended).
Install the host packages listed in the
[Yocto Project system requirements](https://docs.yoctoproject.org/scarthgap/ref-manual/system-requirements.html).

```bash
sudo apt install gawk wget git diffstat unzip texinfo gcc build-essential \
    chrpath socat cpio python3 python3-pip python3-pexpect xz-utils \
    debianutils iputils-ping python3-git python3-jinja2 python3-subunit \
    zstd liblz4-tool file locales libacl1
sudo locale-gen en_US.UTF-8
```

### 2. Fetch the sources

```bash
mkdir -p ~/yocto && cd ~/yocto

git clone git://git.yoctoproject.org/poky -b scarthgap
git clone https://github.com/nhattran02/meta-f1c100s-soc.git
```

### 3. Initialize the build environment

```bash
source poky/oe-init-build-env build
```

### 4. Add the layer

```bash
bitbake-layers add-layer ../meta-f1c100s-soc
bitbake-layers show-layers
```

### 5. Select the machine

Edit `conf/local.conf`:

```bash
MACHINE = "f1c100s-soc"
```

### 6. Build

```bash
bitbake core-image-minimal
```

---

## Build Artifacts

Output files are located in `build/tmp/deploy/images/f1c100s-soc/`:

| File                                         | Description                       |
|----------------------------------------------|-----------------------------------|
| `core-image-minimal-f1c100s-soc.rootfs.wic`  | Bootable SD card image            |
| `core-image-minimal-f1c100s-soc.rootfs.wic.bmap` | Block map for `bmaptool`      |
| `core-image-minimal-f1c100s-soc.rootfs.tar.xz` | Root filesystem tarball         |
| `u-boot-sunxi-with-spl.bin`                  | U-Boot with SPL                   |
| `zImage`                                     | Linux kernel                      |
| `suniv-f1c100s-licheepi-nano.dtb`            | Device Tree blob                  |
| `boot.scr`                                   | Compiled U-Boot boot script       |

---

## SD Card Layout

Defined in [`wic/f1c100s-sdcard.wks`](wic/f1c100s-sdcard.wks):

| Offset  | Content                     | Filesystem | Size     |
|---------|-----------------------------|------------|----------|
| 8 KiB   | `u-boot-sunxi-with-spl.bin` | raw        | —        |
| 1 MiB   | `boot` partition: `zImage`, DTB, `boot.scr` | vfat | 16 MiB |
| next    | `rootfs` partition          | ext4       | rest     |

The F1C100s Boot ROM loads the SPL from the 8 KiB offset of the SD card.

---

## Flashing the Image

Write the image to a microSD card (replace `/dev/sdX` with your card device —
**double-check before running**).

Using [bmaptool](https://github.com/yoctoproject/bmaptool) (recommended, faster):

```bash
cd tmp/deploy/images/f1c100s-soc/
sudo bmaptool copy core-image-minimal-f1c100s-soc.rootfs.wic /dev/sdX
```

Using `dd`:

```bash
sudo dd if=core-image-minimal-f1c100s-soc.rootfs.wic of=/dev/sdX \
    bs=1M conv=fsync status=progress
```

---

## Booting

1. Insert the microSD card into the board.
2. Connect a USB-UART adapter to **UART0** (`ttyS0`, 115200 8N1).
3. Power on the board.

```bash
picocom -b 115200 /dev/ttyUSB0
```

U-Boot runs `boot.scr`, which loads the kernel and DTB from the boot partition:

```
setenv bootargs console=ttyS0,115200 earlycon panic=5 rootwait root=/dev/mmcblk0p2 rw
load mmc 0:1 0x80C00000 suniv-f1c100s-licheepi-nano.dtb
load mmc 0:1 0x80008000 zImage
bootz 0x80008000 - 0x80C00000
```

Login as `root`. With the default poky `local.conf` (`debug-tweaks`), no
password is required.

---

## Kernel Configuration

`linux-yocto` has no BSP for this SoC in `yocto-kernel-cache`, so the
in-layer [`defconfig`](recipes-kernel/linux/files/defconfig) is the complete
kernel configuration (`KCONFIG_MODE = "alldefconfig"`).

To fit the 32 MB RAM budget, the following distro kernel features are removed:
netfilter, nf_tables tests, kernel debug, SCSI debug, GPIO mockup/sim, and
network teaming.

To modify the configuration:

```bash
bitbake linux-yocto -c menuconfig
bitbake linux-yocto -c savedefconfig
```

Then copy the generated `defconfig` back into
`recipes-kernel/linux/files/`.

---
