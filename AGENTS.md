# This is a adbd project for stm32f429i

This project contain kernel patch and entire rootfs building.

## layout
- kernel and bootloader on flash
- TF card via SPI contain rootfs
- VCP with /tty/ACM0

## stack
- buildroot
- git patches
- justfile
