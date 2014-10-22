#include <stdio.h>
#include <unistd.h>
#include "config.h"
#include "server.h"

int main(int argc, char** argv) {

    // parse config.
    if(config_parse(".lab3-config") != 0) {
        printf("failed to read config.\n");
        return 1;
    } else {
        printf("%s\n", config_path);
        printf("%d\n", config_port);
    }

    // limit filesystem access for this process to the folder root.
    chdir(config_path);
    if (chroot(config_path) != 0) {
        perror("chroot");
        return 1;
    }
    setgid(1000);
    setuid(1000);

    // start server.
    if(server_start(config_port) != 0) {
        printf("failed to start server.\n");
        return 1;
    }

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

    printf("exiting server.\n");
    return 0;
}
