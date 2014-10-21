#include "config.h"
#include <stdlib.h>
#include <stdio.h>
#include <stdbool.h>
#include <string.h>

#define CONFIG_KEY_LEN 512
#define CONFIG_VALUE_LEN 1024
#define CONFIG_LINE_LEN 2048

typedef struct {
    char key[CONFIG_KEY_LEN];
    char value[CONFIG_VALUE_LEN];
} pair_t;

static void extract(char* line, pair_t* pair) {
    bool second = false;
    uint16_t offset = 0;
    uint16_t i;
    for(i = 0; line[i] != '\n'; i++) {
        char ch = line[i];
        if(ch == ':') {
            offset = i+1;
            second = true;
            continue;
        }
        if(ch == '\n')
            break;
        if(second == false)
            pair->key[i] = ch;
        else
            pair->value[i-offset] = ch;
    }
}

int config_parse(char* path) {
    FILE* file = fopen(path, "r");
    if(file != NULL) {
        char line[CONFIG_LINE_LEN];
        while(fgets(line, CONFIG_LINE_LEN, file) != NULL) {
            pair_t pair;
            memset(&pair, 0, sizeof(pair_t));

            // convert line to key/value pair.
            extract(line, &pair);

            // set config params.
            if(strcmp(pair.key, "port") == 0) {
                config_port = atoi(pair.value);
            }
            else if(strcmp(pair.key, "path") == 0) {
                memcpy(config_path, pair.value, CONFIG_VALUE_LEN);
            }
        }
    } else {
        return 1;
    }
    fclose(file);
    return 0;
}

