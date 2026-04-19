#!/bin/sh

VERSION=7.0
BUILDROOT_VERSION=2026.02
BUILDROOT_LINUX=`pwd`/buildroot-$BUILDROOT_VERSION/output/build/linux-$VERSION

mkdir -p tmp
cd tmp
if [ ! -d "linux-$VERSION" ]; then
    wget "https://cdn.kernel.org/pub/linux/kernel/v7.x/linux-$VERSION.tar.xz"
    tar xvf linux-$VERSION.tar.xz
fi

make -C $BUILDROOT_LINUX ARCH=arm distclean


diff -urN linux-$VERSION \
    -x ".files-list-*" \
    -x ".applied*" \
    -x ".applied_patches_list" \
    -x ".br_regen_dot_config" \
    -x "*include-prefixes*" \
    -x "*.files-list.before*" \
    ../buildroot-$BUILDROOT_VERSION/output/build/linux-$VERSION > linux.patch
# cd ..
