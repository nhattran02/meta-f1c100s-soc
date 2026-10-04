# Yocto BSP for Allwinner F1C100s SOC

```shell
cd ~

mkdir yocto

cd yocto

git clone git://git.yoctoproject.org/poky -b scarthgap

git clone git://git.openembedded.org/meta-openembedded.git -b scarthgap

git clone https://github.com/nhattran02/meta-f1c100s-soc.git

source poky/oe-init-build-env

```

Add `meta-f1c100s-soc` to `conf/bblayers.conf`

Build
```
bitbake core-image-minimal
```