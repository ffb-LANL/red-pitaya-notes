// server test


#include <stdio.h>
#include <errno.h>
#include <stdlib.h>
#include <limits.h>
#include <stdint.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <math.h>
#include <pthread.h>
#include <sys/mman.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

#define TCP_PORT 1002
int sock_thread = -1;

int interrupted = 0,connected = 0;
void *ctrl_handler(void *arg);
char buffer[1024];
int count=0;

int main(int argc, char *argv[])
{
	  int sock_server, sock_client;
	  pthread_t thread;
	  struct sockaddr_in addr;
	  int yes = 1;
	  ssize_t result;
	  uint64_t command;


	  if((sock_server = socket(AF_INET, SOCK_STREAM, 0)) < 0)
	  {
	    perror("socket");
	    return EXIT_FAILURE;
	  }

  setsockopt(sock_server, SOL_SOCKET, SO_REUSEADDR, (void *)&yes , sizeof(yes));

  /* setup listening address */
  memset(&addr, 0, sizeof(addr));
  addr.sin_family = AF_INET;
  addr.sin_addr.s_addr = htonl(INADDR_ANY);
  addr.sin_port = htons(TCP_PORT);

  if(bind(sock_server, (struct sockaddr *)&addr, sizeof(addr)) < 0)
  {
    perror("bind");
    return 1;
  }
  listen(sock_server, 1024);

  while(!interrupted) {
	  printf("MAIN: waiting for connection\n");
	  if((sock_client = accept(sock_server, NULL, NULL)) < 0)
        {
          perror("accept");
          return 1;
        }
	  printf("new connection, waiting for command\n");
	  connected =1;
	  result = recv(sock_client, (char *)&command, sizeof(command), MSG_WAITALL);
      if( (command >> 60) == 2) break;
	    if(result <= 0 )
	    {
	      close(sock_client);
	      printf("connection closed\n");
	      continue;
	    }
	    if(sock_thread > -1) {
	    	int ret;
	        printf("MAIN: closing thread connection sock=%d\n",sock_thread);
	        ret=shutdown(sock_thread,SHUT_RDWR);
//	    	ret=close(sock_thread);
//	        command = 0x2000000000000000LL;
//	        ret = write(sock_thread, &command, sizeof(command));
	        sleep(10);
	        printf("MAIN: close ret = %d, command = %llx, now sock=%d\n",ret,command,sock_thread);
	    }
	    sock_thread = sock_client;
		printf("Result = %d, sock_client = %d, sock_thread = %d.\nCreating new thread\n", result,sock_client,sock_thread);
	    if(pthread_create(&thread, NULL, ctrl_handler, NULL) < 0)
	        {
	          perror("pthread_create");
	          return EXIT_FAILURE;
	        }
	        pthread_detach(thread);
	       // sleep(10);

  }
  close(sock_client);

printf("Exit program\n");
 return 0;
}

void *ctrl_handler(void *arg)
{
	int sock_client = sock_thread;
	int stop=0,samples;
	uint64_t command;
	uint32_t selector;
	ssize_t result;

	printf("THREAD started: !stop = %d, sock_client = %d\n", !stop,sock_client);
	count++;
	 while(!stop)
	  {
		result = recv(sock_client, (char *)&command, sizeof(command), MSG_WAITALL);
		selector = command >> 60;
	    printf("Thread: sock_client = %d, recv result = %d, command(u) = %llx, selector = %d\n", sock_client, result,command,selector);
	    if( result <= 0) break;
	    switch(selector)
	    {
	    case 0:
               printf("Case 0, !stop = %d\n", !stop);
	             break;
	    case 1:
            stop = 1;
	    	printf("Case 1, leaving thread,!stop = %d\n", !stop);

	  	             break;
	    case 13:
	    	sprintf(buffer,"STATUS: sock_client=%d, res=%d, !stop=%d, command=%llx, selector=%d, count=%d\n",sock_client,result,!stop,command,selector,count);
	      	samples = command & 0xFFFFFFFF;
	        printf("Read %d samples\n",samples);
            if(send(sock_client, buffer, samples, MSG_NOSIGNAL) < 0){   perror("send FIFO");break;}
            break;
	    default:
	        printf("Default case, !stop = %d, command = %llx, selector = %d\n", !stop,command,selector);

	    }
	  }
	  printf("Stopping thread, sock_client=%d, recv result = %d\n",sock_client,result);
	  close(sock_client);
	  sock_thread = -1;

	  return NULL;
}

