#include "http.h"
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/param.h>
#include <sys/socket.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdint.h>
#include <time.h>
#include <limits.h>
#include "logging.h"

#define HTTP_STATUS_OK 200
#define HTTP_STATUS_BAD_REQEST 400
#define HTTP_STATUS_FORBIDDEN 403
#define HTTP_STATUS_NOT_FOUND 404
#define HTTP_STATUS_INTERNAL_SERVER_ERROR 500
#define HTTP_STATUS_NOT_IMPLEMENTED 501

#define HTTP_MESSAGE_LEN 1024
#define HTTP_RESPONSE_LEN 1024
#define HTTP_FILENAME_LEN 1024
#define HTTP_CLF_LEN 1024
#define HTTP_DATE_LEN 256

typedef struct {
    char* ptr;
    size_t size;
    time_t lastModified;
    char* type;
} file_t;

time_t get_mtime(char *path) {
    struct stat statbuf;
    if (stat(path, &statbuf) == -1) {
        perror(path);
        exit(1);
    }
    return statbuf.st_mtime;
}

void get_currentdate(time_t time, char* buffer, uint32_t size) {
    struct tm* tm = localtime(&time);
    strftime(buffer, size, "%a, %d %b %Y %H:%M:%S %Z", tm);
}

void get_currentdateCLF(time_t time, char* buffer, uint32_t size) {
    struct tm* tm = localtime(&time);
    strftime(buffer, size, "%d/%b/%Y:%H:%M:%S %z", tm);
}

int get(char* buf, file_t* file)
{
    // dont allow request with to large filepaths.
    if(strlen(buf) > HTTP_FILENAME_LEN)
        return HTTP_STATUS_BAD_REQEST;
    
    // get filepath.
    char filepath[HTTP_FILENAME_LEN];
    memset(filepath, 0, HTTP_FILENAME_LEN);
    int i;
    for(i = 0; buf[i] != '0'; i++) {
        if(buf[i] == ' ') break;
        filepath[i] = buf[i];
    }

    // resolve path to absoulte path.
    char real[HTTP_FILENAME_LEN];
    if(realpath(filepath, real) == 0) {
        printf("failed to resolve real path name for %s\n", filepath);
    }

    // get content type.
    char* ext = strrchr(real, '.');
    if(ext != NULL) {
        file->type = (char*)malloc(10);
        if(strcmp(ext + 1, "png") == 0)
            strcpy(file->type, "image/png");
        else
            strcpy(file->type, "text/html");
    } else {
        return HTTP_STATUS_NOT_FOUND;
    }

    // get the file content.
    FILE* fp = fopen(real, "rb");
    if(fp == NULL) {
        printf("Failed to open file.. %s\n", real);
        return HTTP_STATUS_NOT_FOUND;
    } else {

        fseek(fp, 0, SEEK_END);
        file->size = ftell(fp);
        fseek(fp, 0, SEEK_SET);

        file->ptr = (char*)malloc(file->size);
        if(fread(file->ptr, 1, file->size, fp) == -1) {
            printf("failed to read %d bytes from %s", file->size, real);
            return HTTP_STATUS_INTERNAL_SERVER_ERROR;
        }
    }
    fclose(fp);

    // get the last modifed date of the file.
    file->lastModified = get_mtime(real);
    
    return HTTP_STATUS_OK;
}

int http_serve(int socket, char* ip) {

    // get current time.
    time_t ct = time(NULL);

    // recv message.
    char msg[HTTP_MESSAGE_LEN];
    memset(msg, 0, HTTP_MESSAGE_LEN);
    if(recv(socket, msg, sizeof(msg), 0) == -1) {
        perror("recv");
        return 1;
    }
    printf("%s\n", msg);

    // tokenize the html message.
    char* nch = strchr(msg,'\n');
    if(nch == NULL)
        return 1;
    
    int size = nch-msg-1;
    char* rq = (char*)malloc(size+1);
    memcpy(rq, msg, size);
    rq[size] = '\0';
        
    // get current date.
    char cdate[HTTP_DATE_LEN];
    get_currentdate(ct, cdate, HTTP_DATE_LEN);

    int result;
    char* response;
    int bytesSent = 0;
    if(rq[0] == 'G' && rq[1] == 'E' && rq[2] == 'T') {
       
        file_t file;
        result = get(&rq[5], &file);

        if(result == HTTP_STATUS_OK) {

            char mdate[HTTP_DATE_LEN];
            get_currentdate(file.lastModified, mdate, HTTP_DATE_LEN);

            response = (char*)malloc(HTTP_RESPONSE_LEN + file.size);
            memset(response, 0, HTTP_RESPONSE_LEN + file.size);

            int size = sprintf(response,
                               "HTTP/1.1 %d OK\n"
                               "Date: %s\n"
                               "Connection: close\n"
                               "Accept-Ranges: bytes\n"
                               "Content-Type: %s\n"
                               "Content-Length: %d\n"
                               "Last-Modified: %s\n\n", result, cdate, file.type, file.size, mdate);

            // copy file data to the end of response message.
            memcpy(response + size, file.ptr, file.size);
            
            free(file.ptr);
            free(file.type);

            bytesSent = file.size;
        }
        
    } else if(rq[0] == 'H' && rq[1] == 'E' && rq[2] == 'A' && rq[3] == 'D') {
        file_t file;
        result = get(&rq[6], &file);
	
        if(result == HTTP_STATUS_OK) {

            char mdate[HTTP_DATE_LEN];
            get_currentdate(file.lastModified, mdate, HTTP_DATE_LEN);    

            response = (char*)malloc(HTTP_RESPONSE_LEN);
            memset(response, 0, HTTP_RESPONSE_LEN);

            sprintf(response,
                    "HTTP/1.1 %d OK\n"
                    "Date: %s\n"
                    "Connection: close\n"
                    "Accept-Ranges: bytes\n"
                    "Content-Type: %s\n"
                    "Content-Length: %d\n"
                    "Last-Modified: %s\n", result, cdate, file.type, file.size, mdate);
            
            free(file.ptr);
            free(file.type);

            bytesSent = file.size;
        }

    } else {
        result = HTTP_STATUS_NOT_IMPLEMENTED;
    }

    if(result != HTTP_STATUS_OK) {
        response = (char*)malloc(HTTP_RESPONSE_LEN);
        memset(response, 0, HTTP_RESPONSE_LEN);
        switch(result) {
        case HTTP_STATUS_BAD_REQEST:
            sprintf(response,"HTTP/1.1 400 Bad Request\n");
            break;
        case HTTP_STATUS_FORBIDDEN:	    
            sprintf(response,"HTTP/1.1 403 Forbidden\n");
            break;
        case HTTP_STATUS_NOT_FOUND:	    
            sprintf(response,"HTTP/1.1 404 Not Found\n");
            break;
        case HTTP_STATUS_INTERNAL_SERVER_ERROR:	    
            sprintf(response,"HTTP/1.1 500 Internal Server Error\n");
            break;
        case HTTP_STATUS_NOT_IMPLEMENTED:
            sprintf(response,"HTTP/1.1 501 Not Implemented\n");
            break;
        default:
            break;
        }
    }
	
    // get the current date in clf format.
    char cdateclf[HTTP_DATE_LEN];
    get_currentdateCLF(ct, cdateclf, HTTP_DATE_LEN);

    // log in CLF format.
    char buf[HTTP_CLF_LEN];
    memset(buf, 0, HTTP_CLF_LEN);
    sprintf(buf, "%s - - [%s] \"%s\" %d %d", ip, cdateclf, rq, result, bytesSent); 
    logging_log(LOG_INFO, buf);
    free(rq);

    // send response.
    if(send(socket, response, HTTP_DATE_LEN + bytesSent, 0) == -1) {
        perror("send");
        return 1;
    }
    printf("%s\n", response);
    free(response);
    return 0;
}
