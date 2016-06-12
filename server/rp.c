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
#include <pthread.h>
/* cfg register map
 * 0-3 control
 * 4-7 RAM record length
 * 8-11 DDS_0 F
 * 12-15 Decimation
 * 20-39 IV module control ~or~
 * 24-27 DDS_1 F
 * 28-31 DDS_delay
 * 40-43 trigger delay
 *
 */
//#define RAM_START 0x0fff0000
#define RAM_START 0x10000000
#define READ_DATA 0x40010000
#define WRITE_DATA 0x40040000
#define WRITE_SIZE 0x0004000
//#define WRITE_DATA 0x40040000
//#define WRITE_SIZE 0x00040000
//#define RAM_START 0x1E000000
#define TCP_PORT 1002
#define SYSTEM_CALL_MAX 2
#define PKTZR_RESET_FLAG 1
#define WRITER_ENABLE_FLAG 2
#define UPDATE_CIC_FLAG 4
#define TRIGGER_RECORD_FLAG 8

#define RECORD_LENGTH_OFFSET 4
#define FREQ_OFFSET 8
#define DESIMATION_OFFSET  12
#define RECORD_START_POS_OFFSET 4
#define WRITER_STS_OFFSET 0
#define VALUE_OFFSET 16
#define RX_FIFO_CNT_OFFSET 24

#define CMD_CONNECT 5
#define CMD_STOP 2
#define CMD_IDN 1

void *ctrl_handler(void *arg);
int interrupted = 0,connected = 0;
int main(int argc, char *argv[])
{
	  pthread_t thread;

  volatile void *rx_data,*tx_data;
  int fd, i, sockServer,sockClient,yes = 1,samples,packet_size=4096, temperature_raw, temperature_offset ;
  double temperature_scale,temperature;
  uint32_t status, trigger_pos, start_offset, end_offset, config;
  unsigned long size = 0, wait;
  uint64_t value;
  uint16_t mask;
  uint64_t command = 600000;
  volatile void *cfg, *ram, *sts;
  char *name = "/dev/mem";
  char *system_call[] ={"cat /root/d.bit > /dev/xdevcfg","cat /root/fd.bit > /dev/xdevcfg"};
  struct sockaddr_in addr;
  size_t length;
  off_t offset=0x8000000;
  samples = 0x10000 * 1024 - 1;
  FILE *fp;
  int verbose=0;
  uint32_t buffer[WRITE_SIZE/4];
  if (argc >=2 ) {
	  if (argv[1][0]=='v' ) verbose = 1;
	  if (argv[1][0]=='V' ) verbose = 2;
  }
  if((fd = open(name, O_RDWR)) < 0)
  {
    perror("open");
    return 1;
  }
  length=(samples+1)*4;
  cfg = mmap(NULL, sysconf(_SC_PAGESIZE), PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0x40000000);
  ram = mmap(NULL,length , PROT_READ|PROT_WRITE, MAP_SHARED, fd, RAM_START);
  sts = mmap(NULL, sysconf(_SC_PAGESIZE), PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0x40001000);
  rx_data = mmap(NULL, 64*sysconf(_SC_PAGESIZE), PROT_READ|PROT_WRITE, MAP_SHARED, fd, READ_DATA);
  tx_data = mmap(NULL, WRITE_SIZE, PROT_READ|PROT_WRITE, MAP_SHARED, fd, WRITE_DATA);
  // reset writer
 //*((uint32_t *)(cfg + 0)) &= ~2;
 //*((uint32_t *)(cfg + 0)) |= 2;

  // enter reset mode for packetizer and fifo
  //*((uint32_t *)(cfg + 0)) &= ~5;
  //value = 50;
 *((uint32_t *)(cfg + 0)) &= ~0xf;
  //*((uint16_t *)(cfg + DESIMATION_OFFSET)) = 100;
  //*((uint32_t *)(cfg + 0)) |= UPDATE_CIC_FLAG;

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
  if(verbose)printf("Temperature scale = %lf, offset = %d, raw = %d\nTemperature = %lf\n", temperature_scale, temperature_offset, temperature_raw, temperature);
  listen(sockServer, 1024);

  while(!interrupted) {
	  if(verbose)printf("waiting on client\n");
	  if((sockClient = accept(sockServer, NULL, NULL)) < 0)
        {
          perror("accept");
          return 1;
        }
	  if(verbose)printf("new connection\n");
	  connected =1;
	  while(!interrupted && connected)
       {
        if(ioctl(sockClient, FIONREAD, &size) < 0){if(verbose)printf("IOCTL\n"); break;}

        if(size >= 8)
        {
          if(recv(sockClient, (char *)&command, 8, MSG_WAITALL) < 0){if(verbose)printf("IOCTL\n");  break;}
          switch(command >> 60)
          {
            case 0:
               	mask = command & 0xFFFF;
            	if(verbose)printf("Sending reset. Mask %x\n",(uint32_t)mask);
            	 /* Reset on*/
            	 *((uint32_t *)(cfg + 0)) &= ~ mask;
                 usleep(1000);
                 /* Reset off */
                 *((uint32_t *)(cfg + 0)) |= mask;


            	 break;

            case 1:

            	samples = command & 0xFFFFFFFF;
            	// reset writer and packetizer
            	  *((uint32_t *)(cfg + 0)) &= 15;//  ( WRITER_ENABLE_FLAG | PKTZR_RESET_FLAG ) ;

         		  // reset trigger
         		  *((uint32_t *)(cfg + 0)) &= ~ TRIGGER_RECORD_FLAG;
            	  // set number of samples
            	  *((uint32_t *)(cfg + RECORD_LENGTH_OFFSET)) = samples;
            	  if(verbose)printf("Entering normal mode. Samples = %d, buffer length = %d bytes\n", samples, length);

            	  // enter normal mode
            	 *((uint32_t *)(cfg + 0)) |= 15; // ( WRITER_ENABLE_FLAG | PKTZR_RESET_FLAG );
            	 // *((uint32_t *)(cfg + 0)) |= PKTZR_RESET_FLAG;
            	//  *((uint32_t *)(cfg + 0)) |=

            	  wait=rand()/1000;
            	  if(verbose)printf("Waiting to trigger for %ld usec\n", wait);
                  usleep(wait);
                  //trigger
                  *((uint32_t *)(cfg + 0)) |= TRIGGER_RECORD_FLAG;
                  sleep(1);
                  if(verbose)printf("Sending data\n");
           		 //read start pos
           		trigger_pos=*((uint32_t *)(sts + RECORD_START_POS_OFFSET));
           		 start_offset=((trigger_pos*2)/packet_size)*packet_size-packet_size;
           		 end_offset=((trigger_pos*2)/packet_size)*packet_size+samples*4-packet_size;
           		 for(offset=0;offset < samples*4;offset +=packet_size)
           		 	 {
           			 	 if(send(sockClient, ram + offset, packet_size, 0) < 0){   perror("send");break;}
           			 }
           		config=*((uint32_t *)(cfg + 0));
           		if(verbose)printf("Start pos = %d, Last offset = %d, Start off = %d, end off = %d, writer sts = %d, offset = %d, config = %x\n",trigger_pos,offset, start_offset, end_offset,*((uint32_t *)(sts + WRITER_STS_OFFSET)),offset,config);
         		  break;
            case 2:
            	connected=0;
            	break;
            case 3: //get status
            	offset = command & 0xFFFFFFFF;
            	 status=*((uint32_t *)(sts + offset));
            	 if(verbose>1)printf("STS Offset =%u, Status = %u\n",(uint32_t)offset, status);
   			 	 if(send(sockClient, sts + offset, sizeof(status), 0) < 0){   perror("send");break;}
            	 break;
            case 4: //get temperature
            	  if((fp = fopen("/sys/bus/iio/devices/iio\:device0/in_temp0_raw", "r")) == NULL){
            	              	  	    perror("device open");
            	              	  	    return 1;
            	              	    }
            	  fscanf(fp,"%d", &temperature_raw);
            	  fclose(fp);
            	  temperature=temperature_scale/1000*(temperature_raw+temperature_offset);
            	  // printf("Temperature scale = %lf, offset = %d, raw = %d\nTemperature = %lf\n", temperature_scale, temperature_offset, temperature_raw, temperature);
            	  if(send(sockClient, &temperature, sizeof(temperature), 0) < 0){   perror("send");break;}
            	  break;
            case 5: //set decimation rate
            	value = command & 0x3;
              	if(verbose)printf("Connect client command, client type = %x\n",(uint32_t)value);
                  break;
            case 6:  // arm

             	samples = command & 0xFFFFFFFF;
             	// reset writer and packetizer
             	  *((uint32_t *)(cfg + 0)) &= ~ ( WRITER_ENABLE_FLAG | PKTZR_RESET_FLAG | TRIGGER_RECORD_FLAG) ;
             	  // set number of samples
             	  *((uint32_t *)(cfg + RECORD_LENGTH_OFFSET)) = samples;
             	 if(verbose)printf("Entering normal mode. Samples = %d, buffer length = %d bytes\n", samples, length);

             	  // enter normal mode
             	 *((uint32_t *)(cfg + 0)) |= ( WRITER_ENABLE_FLAG | PKTZR_RESET_FLAG );
             	 // *((uint32_t *)(cfg + 0)) |= PKTZR_RESET_FLAG;
             	//  *((uint32_t *)(cfg + 0)) |=

             	if(verbose)printf("Armed, status %d\n", *((uint32_t *)(cfg + 0)));
             	   break;
            case 7: //software trigger
                //trigger
                 *((uint32_t *)(cfg + 0)) |= TRIGGER_RECORD_FLAG;
                 if(verbose)printf("Software trigger, status %d\n",*((uint32_t *)(cfg + 0)));
            	break;
            case 8: //read from start of buffer
             	samples = command & 0xFFFFFFFF;
             	if(verbose)printf("Sending %d samples from the start of buffer\n",samples);
          		 //read start pos
          		trigger_pos=*((uint32_t *)(sts + RECORD_START_POS_OFFSET));
          		 start_offset=((trigger_pos*2)/packet_size)*packet_size-packet_size;
          		 end_offset=((trigger_pos*2)/packet_size)*packet_size+samples*4-packet_size;
          		 for(offset=0;offset < samples*4;offset +=packet_size)
          		 	 {
          			 	 if(send(sockClient, ram + offset, packet_size, 0) < 0){   perror("send");break;}
          			 	 if(verbose > 1) if((offset)%(packet_size*256)==0)printf("Offset %d\n",offset);
          		 	 }
          		if(verbose)printf("Offset %d\n",offset);
          		config=*((uint32_t *)(cfg + 0));
          		if(verbose)printf("Start pos = %d, Last offset = %d, Start off = %d, end off = %d, writer sts = %d, config = %x\n",trigger_pos,offset, start_offset, end_offset,*((uint32_t *)(sts + WRITER_STS_OFFSET)),config);
                break;
            case 9: //read data chunk
            	start_offset= command & 0x3FFFFFFF;
            	end_offset = (command  >> 30)& 0x3FFFFFFF;
         		trigger_pos=*((uint32_t *)(sts + RECORD_START_POS_OFFSET));
         		if(verbose)printf("Sending data, start = %d, end = %d, trigger pos = %d\n", start_offset,end_offset,trigger_pos);
          		 for(offset=start_offset;offset < end_offset;offset +=packet_size)
          		 	 {
          			 	 if(send(sockClient, ram + offset, packet_size, 0) < 0){   perror("send");break;}
          			 	 if(verbose > 1) if((offset-start_offset)%(packet_size*128)==0)printf("Offset %d\n",offset);
          		 	 }
          		if(verbose)printf("Last offset %d\n",offset);
          		config=*((uint32_t *)(cfg + 0));
          		if(verbose)printf("writer sts = %d, config = %x\n",*((uint32_t *)(sts + WRITER_STS_OFFSET)),config);
                break;
            case 10:
            	i = command & 0xFFFF;
            	if(i < SYSTEM_CALL_MAX) {
            		if(verbose)printf("Call: %s\n",system_call[i]);
            		system(system_call[i]);
            	}
            	break;
            case 11: //get config
            	offset = command & 0xFFFFFFFF;
            	 status=*((uint32_t *)(cfg + offset));
            	 if(verbose)printf("CFG Offset =%u, Status = %u\n",(uint32_t)offset, status);
   			 	 if(send(sockClient, cfg + offset, sizeof(status), 0) < 0){   perror("send");break;}
            	 break;
            case 12: //set config
            	offset = (command >> 32)& 0xFF;
            	 status=command & 0xFFFFFFFF;
            	 if(verbose)printf("Set CFG Offset =%u, State = %u\n",(uint32_t)offset, status);
            	 *((uint32_t *)(cfg + offset)) = status;
   			 	 break;
            case 13: // read RX FIFO
            	samples = command & 0xFFFFFFFF;
            	if(verbose>1)printf("Read %d u32. FIFO Counter =%u\n",samples,*((uint32_t *)(sts + RX_FIFO_CNT_OFFSET)));
            	//while(*((uint32_t *)(sts + RX_FIFO_CNT_OFFSET))< 4096)usleep(500);
            	//memcpy(buffer, rx_data, samples);
            	for(i = 0; i < samples; ++i) buffer[i] = *((uint32_t *)rx_data);
            	if(verbose>1)printf("After read FIFO. Counter =%u\n",*((uint32_t *)(sts + RX_FIFO_CNT_OFFSET)));
                if(send(sockClient, buffer, samples*4, MSG_NOSIGNAL) < 0){   perror("send FIFO");break;}
            	if(verbose){
            		printf("First words in RX buffer=");
                        		for (int i=0;i<15;++i)
                        			printf("%d, ",buffer[i] );
                    printf("\n");
            	}
                break;
            case 14: //generate test pattern

             	samples = command & 0xFFFFFFFF;
             	// reset writer and packetizer
             	  *((uint32_t *)(cfg + 0)) &= ~ ( WRITER_ENABLE_FLAG | PKTZR_RESET_FLAG ) ;
          		  // reset trigger
          		  *((uint32_t *)(cfg + 0)) &= ~ TRIGGER_RECORD_FLAG;
             	  // set number of samples
             	  *((uint32_t *)(cfg + RECORD_LENGTH_OFFSET)) = samples;
             	 if(verbose)printf("Setting up test pattern. Samples = %d, buffer length = %d bytes\n", samples, length);
             	  // enter normal mode
             	 *((uint32_t *)(cfg + 0)) |= ( WRITER_ENABLE_FLAG | PKTZR_RESET_FLAG );

             	if(verbose)printf("Armed for pattern, status %d\n", *((uint32_t *)(cfg + 0)));
                //trigger
                 *((uint32_t *)(cfg + 0)) |= TRIGGER_RECORD_FLAG;
            	usleep(20);


                  *((uint32_t *)(cfg + 8)) = (uint32_t)3470334;
                  usleep(10);
                  *((uint32_t *)(cfg + 8)) = (uint32_t)34703340;
                  usleep(10);
                  *((uint32_t *)(cfg + 8)) = (uint32_t)347033400;
                //  usleep(10);
                //  *((uint32_t *)(cfg + 8)) = (uint32_t)3470334;
           		  break;
            case 15: //Receive a batch of frequencies
             	samples = command & 0xFFFFFFFF;
             	if(verbose)printf("Writing %d u32 words\n",samples);
             	if(recv(sockClient, buffer, samples*4, MSG_WAITALL) < 0) break;
            	for(i = 0; i < samples; ++i) *((uint32_t *)tx_data)=buffer[i];
            	//memcpy( tx_data, buffer,samples);
            	if(verbose){
            		printf("First words in TX buffer=");
                        		for (int i=0;i<15;++i)
                        			printf("%d, ",buffer[i] );
                    printf("\n");
            	}
                break;
            }
          }
       }
	  if(verbose)printf("Connection lost\n");
    close(sockClient);
  }
if(verbose)printf("closed connection\n");



  munmap(cfg, sysconf(_SC_PAGESIZE));
  munmap(ram, sysconf(_SC_PAGESIZE));
  munmap(sts, sysconf(_SC_PAGESIZE));
  munmap(rx_data, sysconf(_SC_PAGESIZE));
  return 0;
}

void *ctrl_handler(void *arg)
{
	printf("Closing thread\n");
	return NULL;
}
