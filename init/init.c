#include <stdio.h>
#include <sys/mount.h>
#include <unistd.h>
#include <string.h>
#include <errno.h>

int main()
{
    int i, ret;

    printf("Init starting\n");
    mount("proc", "/proc", "proc", 0, NULL);
    mount("sysfs", "/sys", "sysfs", 0, NULL);
    mount("devtmpfs", "/dev", "devtmpfs", 0, NULL);

    while (mount("/dev/mmcblk0", "/mnt", "ext2", 0, 0)!=0) {
        usleep(100000);
        printf("Mounting rootfs fail...\n");
    }

    chdir("/mnt");
    mount("/mnt", "/", NULL, MS_MOVE, NULL);
    chroot(".");
    chdir("/");

    char *a[] = {"sh", NULL};
    char *e[] = {"PATH=/bin:/sbin:/usr/bin:/usr/sbin", NULL};
    execve("/bin/sh", a, e);
    printf("ERR sh: %s\n", strerror(errno));

    while (1) pause();
    return 0;
}
