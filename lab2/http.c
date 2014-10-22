#include "http.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#define HTTP_FILENAME_LEN 1024

static http_content_t http_get(char* buf)
{
    http_content_t content;

    char filename[HTTP_FILENAME_LEN];
    memset(filename, 0, HTTP_FILENAME_LEN);

    int i;
    for(i = 0; buf[i] != ' '; i++) {
        filename[i] = buf[i];
    }

    printf("serving file %s\n", filename);

    FILE* file = fopen(filename, "r");
    if(file == NULL) {
        printf("Failed to open file.. %s\n", filename);
        content.code = HTTP_STATUS_NOT_FOUND;
        return content;
    } else {

        fseek(file, 0, SEEK_END);
        content.filesize = ftell(file);
        fseek(file, 0, SEEK_SET);

        content.file = (char*)malloc(content.filesize);
        if(fread(content.file, 1, content.filesize, file) == -1) {
            printf("failed to read %d bytes from %s", content.filesize, buf);
            content.code = HTTP_STATUS_INTERNAL_SERVER_ERROR;
            return content;
        }
    }
    close(file);
    content.code = HTTP_STATUS_OK;
    printf("%s\n", content.file);
    return content;
}

http_content_t http_parse(char* msg)
{
    http_content_t content;

    //TODO: Log msg.

    if(msg[0] == 'G' && msg[1] == 'E' && msg[2] == 'T') {
        content = http_get(&msg[5]);
    } else {
        content.code = HTTP_STATUS_NOT_IMPLEMENTED;
    }
    return content;
}
