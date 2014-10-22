#include "logging.h"
#include <stdlib.h>

int logging_init(char* file) {
    if(file[0] == NULL) {
	printf("Logging to syslog.\n");
	openlog("webs", LOG_CONS, LOG_DAEMON);
	logging_mode = LOGGING_MODE_SYSLOG;
    } else {
	printf("Logging to %s\n", file);
	logging_mode = LOGGING_MODE_FILE;
    }
}

int logging_shutdown()
{
    if(logging_mode == LOGGING_MODE_SYSLOG) {
	closelog();
    }
}

void logging_log(int level, char* msg) {

// check strings for possible overflow.
    
    syslog(level, msg);
}



