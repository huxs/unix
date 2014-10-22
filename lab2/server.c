#include "server.h"
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/select.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <time.h>
#include "http.h"

int server_start(uint16_t port) {

    fd_set master;
    fd_set read_fds;
    int fdmax;

    FD_ZERO(&master);
    FD_ZERO(&read_fds);

    struct sockaddr_in serv_addr, pin;

    int sd, sd_current;

    if((sd = socket(AF_INET, SOCK_STREAM, 0)) == -1) {
        perror("socket");
        return 1;
    }

    memset(&serv_addr, 0, sizeof(serv_addr));
    serv_addr.sin_family = AF_INET;
    serv_addr.sin_addr.s_addr = INADDR_ANY;
    serv_addr.sin_port = htons(port);

    if(bind(sd, (struct sockaddr*)&serv_addr, sizeof(serv_addr)) == -1) {
        perror("bind");
        return 1;
    }

    if(listen(sd, 10) == -1) {
        perror("listen");
        return 1;
    }

    FD_SET(sd, &master);
    fdmax = sd;
    while(1) {

        read_fds = master;
        if(select(fdmax+1, &read_fds, NULL, NULL, NULL) == -1) {
            perror("select");
            return 1;
            }

        int i;
        for(i = 0; i <= fdmax; i++) {
            if(FD_ISSET(i, &read_fds)) {
                printf("socket %d ready.\n", i);
                if(i == sd) {

                    socklen_t addrlen = sizeof(pin);
                    if((sd_current = accept(sd, (struct sockaddr*)&pin, &addrlen)) == -1) {
                        perror("accept");
                        return 1;
                    }
                    printf("accepted %d\n", sd_current);

                    FD_SET(sd_current, &master);
                    if(sd_current > fdmax) {
                        fdmax = sd_current;
                    }

                    printf("Request from %s:%i\n", inet_ntoa(pin.sin_addr), ntohs(pin.sin_port));
                } else {

                    if(http_serve(i) != 0) {
                        printf("failed to serve http request.\n");
                    }

                    close(i);
                    FD_CLR(i, &master);
                }
            }
        }
    }

    close(sd);
    close(sd_current);
    return 0;
}
