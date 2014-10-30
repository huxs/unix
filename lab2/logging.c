#include "logging.h"
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#define LOGGING_SYSLOG_MAX 1024

FILE* file;

int logging_init(char* filename) {
    if(filename[0] == '\0') {
        printf("Logging to syslog.\n");
         openlog("webs", LOG_CONS, LOG_DAEMON);
        logging_mode = LOGGING_MODE_SYSLOG;
    } else {
        printf("Logging to %s\n", filename);
        logging_mode = LOGGING_MODE_FILE;
        file = fopen(filename, "a");
        if(file == NULL) {
            printf("failed to open file %s\n", filename);
            return 1;
        }
    }
    return 0;
}

int logging_shutdown() {
    if(logging_mode == LOGGING_MODE_SYSLOG) {
        closelog();
    } else if(logging_mode == LOGGING_MODE_FILE) {
        fclose(file);
    }
    return 0;
}

void logging_log(int level, char* msg) {

    if(logging_mode == LOGGING_MODE_SYSLOG) {
        // check strings for possible overflow.
        if(strlen(msg) < LOGGING_SYSLOG_MAX)
            syslog(level, "%s", msg);
    }
    else if(logging_mode == LOGGING_MODE_FILE) {
        if(file != NULL) {
            fprintf(file, "%s\n", msg);
            fflush(file);
        } else {
            printf("No file open, forgot to do logging_init?");
        }
    }
}



