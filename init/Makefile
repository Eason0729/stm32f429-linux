CC=`pwd`/../buildroot-2026.02/output/host/bin/arm-linux-gcc
CFLAGS?=-Os -mcpu=cortex-m4 -mthumb -mfdpic

init: init.c
	$(CC) init.c -o init $(CFLAGS)
