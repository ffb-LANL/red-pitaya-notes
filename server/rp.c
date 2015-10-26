#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <unistd.h>
#include <stdlib.h>
#include <sys/mman.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/ioctl.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#define RAM_START 0x10000000
#define TCP_PORT 1002

int interrupted = 0;
int main()
{
  int fd, i, sockServer,sockClient,yes = 1,samples,packet_size=4096, ch,temperature_raw, temperature_offset ;
  double temperature_scale,temperature;
  uint32_t status, start_pos, start_offset, end_offset;
  unsigned long size = 0, wait;
  int16_t value;
  uint64_t command = 600000;
  void *cfg, *ram, *sts;
  char *name = "/dev/mem";
  struct sockaddr_in addr;
  size_t length;
  off_t offset=0x8000000;
  samples = 0x10000 * 1024 - 1;
  FILE *fp;
  if((fd = open(name, O_RDWR)) < 0)
  {
    perror("open");
    return 1;
  }
  length=(samples+1)*4;
  cfg = mmap(NULL, sysconf(_SC_PAGESIZE), PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0x40000000);
  ram = mmap(NULL,length , PROT_READ|PROT_WRITE, MAP_SHARED, fd, RAM_START);
  sts = mmap(NULL, sysconf(_SC_PAGESIZE), PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0x40001000);
  // reset writer
 //*((uint32_t *)(cfg + 0)) &= ~2;
 //*((uint32_t *)(cfg + 0)) |= 2;

  // enter reset mode for packetizer and fifo
  //*((uint32_t *)(cfg + 0)) &= ~5;


  if((sockServer = socket(AF_INET, SOCK_STREAM, 0)) < 0)
  {
    perror("socket");
    return 1;
  }
  setsockopt(sockServer, SOL_SOCKET, SO_REUSEADDR, (void *)&yes , sizeof(yes));
  /* setup listening address */
  memset(&addr, 0, sizeof(addr));
  addr.sin_family = AF_INET;
  addr.sin_addr.s_addr = htonl(INADDR_ANY);
  addr.sin_port = htons(TCP_PORT);

  if(bind(sockServer, (struct sockaddr *)&addr, sizeof(addr)) < 0)
  {
    perror("bind");
    return 1;
  }

  if((fp = fopen("/sys/bus/iio/devices/iio\:device0/in_temp0_offset", "r")) == NULL){
	    perror("device open");
	    return 1;
  }
  fscanf(fp,"%d", &temperature_offset);
  fclose(fp);
  if((fp = fopen("/sys/bus/iio/devices/iio\:device0/in_temp0_scale", "r")) == NULL){
  	    perror("device open");
  	    return 1;
    }
  fscanf(fp,"%lf", &temperature_scale);
  fclose(fp);
  if((fp = fopen("/sys/bus/iio/devices/iio\:device0/in_temp0_raw", "r")) == NULL){
  	    perror("device open");
  	    return 1;
    }
  fscanf(fp,"%d", &temperature_raw);
  fclose(fp);
  temperature=temperature_scale/1000*(temperature_raw+temperature_offset);
  printf("Temperature scale = %lf, offset = %d, raw = %d\nTemperature = %lf\n", temperature_scale, temperature_offset, temperature_raw, temperature);
  listen(sockServer, 1024);
  printf("waiting on client\n");
  if((sockClient = accept(sockServer, NULL, NULL)) < 0)
        {
          perror("accept");
          return 1;
        }
  printf("new connection\n");
  while(!interrupted)
      {
        if(ioctl(sockClient, FIONREAD, &size) < 0) break;

        if(size >= 8)
        {
          if(recv(sockClient, (char *)&command, 8, MSG_WAITALL) < 0) break;
          switch(command >> 60)
          {
            case 0:
            	printf("Sending phase word %d\n",(int)command);
                /* set phase increment */
                *((uint32_t *)(cfg + 8)) = (uint32_t)command;
              	break;

            case 1:

            	samples = command & 0xFFFFFFFF;
            	// reset writer
            	  *((uint32_t *)(cfg + 0)) &= ~2;

         		  // enter reset mode for packetizer and fifo
         		  *((uint32_t *)(cfg + 0)) &= ~ 5;
         		  *((uint32_t *)(cfg + 0)) &= ~ 8;
            	  // set number of samples
            	  *((uint32_t *)(cfg + 4)) = samples;
            	  printf("Entering normal mode. Samples = %d, buffer length = %d bytes\n", samples, length);

            	  // enter normal mode
            	  *((uint32_t *)(cfg + 0)) |= 2;
            	  *((uint32_t *)(cfg + 0)) |= 5;
            	  wait=rand()/1000;
            	  printf("Waiting to trigger for %ld usec\n", wait);
                  	  usleep(wait);
                  //trigger
                	  *((uint32_t *)(cfg + 0)) |= 8;
                  	  sleep(1);
           		 printf("Sending data\n");
           		 //read start pos
           		 start_pos=*((uint32_t *)(sts + 4));
           		 start_offset=((start_pos*2)/packet_size)*packet_size-packet_size;
           		 end_offset=((start_pos*2)/packet_size)*packet_size+samples*4-packet_size;
           		 for(offset=0;offset < 0x300000*4;offset +=packet_size)
           		 	 {
           			 	 if(send(sockClient, ram + offset, packet_size, 0) < 0){   perror("send");break;}
           			 	 //printf("%d\r",offset);
           		 	 }
           		 printf("Start pos = %d, Last offset = %d, Start off = %d, end off = %d\n",start_pos,offset, start_offset, end_offset);
         		  break;
            case 2:
            	interrupted=1;
            	break;
            case 3: //get status
            	offset = command & 0xFFFFFFFF;
            	 status=*((uint32_t *)(sts + offset));
            	 printf("Status = %u\n",status);
   			 	 if(send(sockClient, sts + offset, sizeof(status), 0) < 0){   perror("send");break;}
            	 break;
            case 4: //get temperature
            	 if((fp = fopen("/sys/bus/iio/devices/iio\:device0/in_temp0_raw", "r")) == NULL){
            	  	    perror("device open");
            	  	    return 1;
            	    }
            	  fscanf(fp,"%d", &temperature);
            	  fclose(fp);
            	  temperature=temperature_scale/1000*(temperature_raw+temperature_offset);
            	  printf("Temperature scale = %lf, offset = %d, raw = %d\nTemperature = %lf\n", temperature_scale, temperature_offset, temperature_raw, temperature);
            	  if(send(sockClient, &temperature, sizeof(temperature), 0) < 0){   perror("send");break;}
            	  break;

          }
        }
      }
close(sockClient);
printf("closed connection\n");



  munmap(cfg, sysconf(_SC_PAGESIZE));
  munmap(ram, sysconf(_SC_PAGESIZE));

  return 0;
}
