#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <signal.h>
#include <sched.h>
#include <fcntl.h>
#include <math.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <sys/ioctl.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

#define TCP_PORT 1002

// Commands
#define CMD_CONNECT 5
#define CMD_STOP 2
#define CMD_IDN 1


int interrupted = 0;
int verbose=0;

void signal_handler(int sig)
{
  interrupted = 1;
}



int main (int argc, char *argv[])
{
  int fd, sock_server, sock_client,yes=1;
  struct sockaddr_in addr;
  uint64_t command;
  uint8_t code;

  if (argc >=2 ) {
	  if (argv[1][0]=='v' ) verbose = 1;
	  if (argv[1][0]=='V' ) verbose = 2;
  }

  if((sock_server = socket(AF_INET, SOCK_STREAM, 0)) < 0)
  {
    perror("socket");
    return EXIT_FAILURE;
  }

  setsockopt(sock_server, SOL_SOCKET, SO_REUSEADDR, (void *)&yes, sizeof(yes));

  /* setup listening address */
  memset(&addr, 0, sizeof(addr));
  addr.sin_family = AF_INET;
  addr.sin_addr.s_addr = htonl(INADDR_ANY);
  addr.sin_port = htons(TCP_PORT);

  if(bind(sock_server, (struct sockaddr *)&addr, sizeof(addr)) < 0)
  {
    perror("bind");
    return EXIT_FAILURE;
  }

  listen(sock_server, 1024);

  while(!interrupted)
  {
    if(verbose)printf("waiting for client\n");
    if((sock_client = accept(sock_server, NULL, NULL)) < 0)
    {
      perror("accept");
      return EXIT_FAILURE;
    }
    if(verbose)printf("new connection, waiting for command\n");
    int result,status=109 << 16;
    uint32_t IDN=0xb00b;
    result = recv(sock_client, (char *)&command, sizeof(command), MSG_WAITALL);
    if(result >= sizeof(command) )
    {
	   switch(command >> 60)
	   {
	       case CMD_IDN:
	    	   if(verbose)printf("MAIN: IDN query, socket=%d\n",sock_client);
			   status = ( status & 0xffff0000 ) | (IDN & 0x0000ffff );
	 		   if(send(sock_client, &status, sizeof(status), 0) < 0){   perror("send");interrupted=1;break;}
	 		   close(sock_client);
	    	   break;
	       case CMD_STOP:
	    	   close(sock_client);
	    	   if(verbose)printf("Exit program\n");
	    	   return EXIT_SUCCESS;
	    	 break;
	       case CMD_CONNECT:
    	       	 if(verbose)printf("Client connect request\n");
	    	 break;
               case 3: //get status
          	if(verbose>1)printf("Status request\n");
 			if(send(sock_client, &status, sizeof(status), 0) < 0){   perror("send");interrupted=1;break;}
          	break;
	       default:
		 if(verbose)printf("Unexpected command, closing connection, socket = %d\n",sock_client);
		 close(sock_client);
             break;
            }
        
    }

    signal(SIGINT, signal_handler);
    signal(SIGINT, SIG_DFL);
    close(sock_client);
  }

  close(sock_server);

  return EXIT_SUCCESS;
}