#ifndef __LOGGING_H__
#define __LOGGING_H__

#include <syslog.h>

#define LOGGING_MODE_SYSLOG 0
#define LOGGING_MODE_FILE 1

int logging_mode;

int logging_init(char* file);
int logging_shutdown();
void logging_log(int level, char* msg);

#endif
