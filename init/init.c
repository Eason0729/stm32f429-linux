#include <stdio.h>
#include <sys/mount.h>
#include <stdlib.h>
#include <unistd.h>


int main()
{
    printf("Mounting rootfs\n");
    mount("proc", "/proc", "proc", 0, NULL);
    while (mount("/dev/mmcblk0p1", "/root", "ext2", 0, 0));

    char *argv[] = { "sh", NULL };
    char *envp[] = {"PATH=/root/bin", NULL};
    execve("/root/bin/sh", argv, envp);
}
