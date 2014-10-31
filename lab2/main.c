#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <unistd.h>
#include <getopt.h>
#include <string.h>
#include "config.h"
#include "server.h"
#include "logging.h"

int main(int argc, char** argv) {

    bool daemonize = false;
    char logfile[1024];
    memset(logfile, 0, 1024);

    // parse config file.
    if(config_parse(".lab3-config") != 0) {
        printf("failed to read config.\n");
        return 1;
    }

    // parse command line.
    int c;
    while ((c = getopt (argc, argv, "p:dl:")) != -1)
        switch (c) {
        case 'p':
            config_port = atoi(optarg);
            break;
        case 'd':
            daemonize = true;
            break;
        case 'l':
            memcpy(logfile, optarg, strlen(optarg));
            break;
        case '?':
            if (optopt == 'p' || optopt == 'l')
                fprintf(stderr, "Option %c requires an argument.\n", optopt);
            else if (isprint (optopt))
                fprintf(stderr, "Unknown option `-%c'.\n", optopt);
            else
                fprintf(stderr, "Unknown option character `\\x%x'.\n", optopt);
            return 1;
        default:
            abort();
        }

    // print config values.
    printf("%s\n", config_path);
    printf("%d\n", config_port);

    // initialize logging.
    logging_init(logfile);
    logging_log(LOG_INFO, "Starting server..");
    
    // daemonize the process.
    if(daemonize == true) {
        umask(0);
        pid_t pid = fork();
        if(pid != 0)
            exit(0);
        setsid();

        pid = fork();
        if(pid != 0)
            exit(0);

        pid = getpid();
        printf("PID:%ld\n", (long)pid);
    }

    // start server.
    if(server_start(config_port, config_path) != 0) {
        printf("failed to start server.\n");
        return 1;
    }

    logging_shutdown();
    
    printf("exiting server.\n");
    return 0;
}
