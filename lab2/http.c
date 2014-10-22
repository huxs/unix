#include "http.h"
#include <sys/types.h>
#include <sys/stat.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdint.h>
#include <time.h>

#define HTTP_STATUS_OK 200
#define HTTP_STATUS_BAD_REQEST 400
#define HTTP_STATUS_FORBIDDEN 403
#define HTTP_STATUS_NOT_FOUND 404
#define HTTP_STATUS_INTERNAL_SERVER_ERROR 500
#define HTTP_STATUS_NOT_IMPLEMENTED 501

#define HTTP_FILENAME_LEN 1024
#define HTTP_DATE_LEN 1024
#define HTTP_MESSAGE_LEN 1024
#define HTTP_RESPONSE_LEN 8192

typedef struct {
    char* ptr;
    size_t size;
    time_t lastModified;
} file_t;


time_t get_mtime(char *path)
{
    struct stat statbuf;
    if (stat(path, &statbuf) == -1) {
        perror(path);
        exit(1);
    }
    return statbuf.st_mtime;
}

static int get(char* buf, file_t* file)
{
    // get filename.
    char filename[HTTP_FILENAME_LEN];
    memset(filename, 0, HTTP_FILENAME_LEN);
    int i;
    for(i = 0; buf[i] != '0'; i++) {
        if(buf[i] == ' ') break;
        filename[i] = buf[i];
    }

    //TODO: URL validate.

    FILE* fp = fopen(filename, "r");
    if(fp == NULL) {
        printf("Failed to open file.. %s\n", filename);
        return HTTP_STATUS_NOT_FOUND;
    } else {

        fseek(fp, 0, SEEK_END);
        file->size = ftell(fp);
        fseek(fp, 0, SEEK_SET);

        file->ptr = (char*)malloc(file->size);
        if(fread(file->ptr, 1, file->size, fp) == -1) {
            printf("failed to read %d bytes from %s", file->size, filename);
            return HTTP_STATUS_INTERNAL_SERVER_ERROR;
        }
    }
    close(fp);


    file->lastModified = get_mtime(filename);
    
    return HTTP_STATUS_OK;
}

static void http_getdate(time_t time, char* buffer, uint32_t size)
{
    struct tm* tm = localtime(&time);
    strftime(buffer, size, "%a, %d %b %Y %H:%M:%S %Z", tm);
}

int http_serve(int socket) {

    // recv message.
    char msg[HTTP_MESSAGE_LEN];
    memset(msg, 0, HTTP_MESSAGE_LEN);
    if(recv(socket, msg, sizeof(msg), 0) == -1) {
        perror("recv");
        return 1;
    }

    //TODO log.

    // get current date.
    char cdate[HTTP_DATE_LEN];
    char mdate[HTTP_DATE_LEN];
    time_t ct = time(NULL);
    http_getdate(ct, cdate, HTTP_DATE_LEN);
    
    char response[HTTP_RESPONSE_LEN];
    memset(response, 0, HTTP_RESPONSE_LEN);

    int result;
    if(msg[0] == 'G' && msg[1] == 'E' && msg[2] == 'T') {
        file_t file;
        result = get(&msg[5], &file);

	http_getdate(file.lastModified, mdate, HTTP_DATE_LEN);
	
        if(result == HTTP_STATUS_OK) {
            sprintf(response,
                    "HTTP/1.1 %d OK\n"
                    "Date: %s\n"
                    "Connection: close\n"
                    "Accept-Ranges: bytes\n"
                    "Content-Type: text/html\n"
                    "Content-Length: %d\n"
                    "Last-Modified: %s\n"
                    "%s\n", result, cdate, file.size, mdate, file.ptr);
            free(file.ptr);
        }


    } else if(msg[0] == 'H' && msg[1] == 'E' && msg[2] == 'A' && msg[3] == 'D') {
        file_t file;
        result = get(&msg[6], &file);

	http_getdate(file.lastModified, mdate, HTTP_DATE_LEN);
	
        if(result == HTTP_STATUS_OK) {
            sprintf(response,
                    "HTTP/1.1 %d OK\n"
                    "Date: %s\n"
                    "Connection: close\n"
                    "Accept-Ranges: bytes\n"
                    "Content-Type: text/html\n"
                    "Content-Length: %d\n"
                    "Last-Modified: %s\n", result, cdate, file.size, mdate);
            free(file.ptr);
        }

    } else {
        result = HTTP_STATUS_NOT_IMPLEMENTED;
    }

    printf("%s\n", response);

    // send response.
    if(send(socket, response, strlen(response), 0) == -1) {
        perror("send");
        return 1;
    }
    return 0;
}