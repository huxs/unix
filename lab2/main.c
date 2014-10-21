#include <stdio.h>
#include <unistd.h>
#include "config.h"

int main(int argc, char** argv) {
    printf("starting server.\n");

    if(config_parse(".lab3-config") != 0) {
        printf("failed to read config.\n");
        return 1;
    } else {
        printf("Path to docs:%s\n", config_path);
        printf("Port to listen to:%d\n", config_port);
    }
    /*
    // limit filesystem access for this process to the folder root.
    chdir("/root");
    if (chroot("/root") != 0) {
        perror("chroot /root");
        return 1;
    }
    setgid(1000);
    setuid(1000);*/

/*
    // daemonize the process.
    umask(0);
    pid_t pid = fork();
    if(pid != 0)
        exit(0);
    setsid();

    if(pid != 0)
        exit(0);

    printf("PID:%d\n", pid);
*/

    //while(1) {}

    printf("exiting server.\n");
    return 0;
}
