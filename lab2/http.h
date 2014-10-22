#ifndef __HTTP_H__
#define __HTTP_H__

#include <stdlib.h>
#include <stdint.h>

#define HTTP_STATUS_OK "200 OK"
#define HTTP_STATUS_BAD_REQUEST "400 Bad Request"
#define HTTP_STATUS_FORBIDDEN "403 Forbidden"
#define HTTP_STATUS_NOT_FOUND "404 Not Found"
#define HTTP_STATUS_INTERNAL_SERVER_ERROR "500 Internal Server Error"
#define HTTP_STATUS_NOT_IMPLEMENTED "501 Not Implemented"

typedef struct
{
    char* code;
    char* file;
    size_t filesize;
} http_content_t;

http_content_t http_parse(char* msg);

#endif
