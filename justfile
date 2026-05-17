set shell := ["nu", "-c"]

BUILDROOT_VERSION := "2026.02"
BUILDROOT_DIR := justfile_directory() + "/buildroot-" + BUILDROOT_VERSION
BUILDROOT_TAR := "buildroot-" + BUILDROOT_VERSION + ".tar.xz"

default:
    just --list

all: fetch defconfig build

fetch:
    ^chmod +x scripts/fetch.sh
    ^./scripts/fetch.sh

defconfig:
    make -C {{ BUILDROOT_DIR }} stm32f429_disco_xip_defconfig

initromfs:
    make -C init
    ^rm -rf rootfs
    mkdir rootfs
    mkdir rootfs/bin
    mkdir rootfs/dev
    mkdir rootfs/lib
    mkdir rootfs/proc
    mkdir rootfs/mnt
    mkdir rootfs/usr
    mkdir rootfs/usr/sbin
    mv init/init rootfs
    # TODO: copy additional package into rootfs/usr/sbin/
    ^cp -a -d {{ BUILDROOT_DIR }}/output/target/lib/* rootfs/lib
    ^cp -a -d {{ BUILDROOT_DIR }}/output/target/usr/lib/* rootfs/lib
    ^{{ BUILDROOT_DIR }}/output/host/bin/genromfs -d rootfs -f {{ BUILDROOT_DIR }}/output/images/rootfs.romfs

build:
    make -C {{ BUILDROOT_DIR }} -j (sys cpu | length)
    just initromfs

linux-rebuild:
    make -C {{ BUILDROOT_DIR }} linux-rebuild -j (sys cpu | length)

flash:
    ^{{ BUILDROOT_DIR }}/board/stmicroelectronics/stm32f429-disco/flash.sh {{ BUILDROOT_DIR }}/output stm32f429discovery

sd-card:
    ./scripts/prepare_sd.sh

test-usb:
    python3 client/host_client.py

clean:
    rm -r ./mnt
    rm -r ./rootfs
    rm ./rootfs.ext2
    rm ./buildroot-2026.02.tar.xz
