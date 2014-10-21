#ifndef __CONFIG_H__
#define __CONFIG_H__

#include <stdint.h>

// config variables.
uint16_t config_port;
char config_path[1024];

// simple line parser which parse lines of follwing structure, key:value
int config_parse(char* path);

#endif
