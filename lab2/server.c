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
#include <fcntl.h>
#include <pwd.h>
#include <grp.h>
#include "http.h"

void drop_priv(char* path)
{
    // limit filesystem access for this process to the folder root.
    struct passwd *pwd;
    struct group *grp;
    
    if ((pwd = getpwnam("daniel")) == 0) {
    	fprintf(stderr, "User not found in /etc/passwd\n");
    	exit(1);
    }

    if ((grp = getgrnam("daniel")) == 0) {
    	fprintf(stderr, "Group not found in /etc/group\n");
        exit(1);
    }

    chdir(path);
    if (chroot(path) != 0) {
        perror("chroot");
        exit(1);
    }
    
    setgid(grp->gr_gid);
    setuid(pwd->pw_uid);
}

int server_start(uint16_t port, char* path) {

    fd_set master;
    fd_set read_fds;
    int fdmax;

    FD_ZERO(&master);
    FD_ZERO(&read_fds);

    struct sockaddr_in serv_addr, pin;

    int sd;

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

    drop_priv(path);

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
                    if((i = accept(sd, (struct sockaddr*)&pin, &addrlen)) == -1) {
                        perror("accept");
                        return 1;
                    }
                    printf("accepted %d\n", i);

                    FD_SET(i, &master);
                    if(i > fdmax) {
                        fdmax = i;
                    }

                    printf("Request from %s:%i\n", inet_ntoa(pin.sin_addr), ntohs(pin.sin_port));
                } else {

                    if(http_serve(i, inet_ntoa(pin.sin_addr)) != 0) {
                        printf("failed to serve http request.\n");
                    }

                    close(i);
                    FD_CLR(i, &master);
                }
            }
        }
    }

    close(sd);
    return 0;
}
