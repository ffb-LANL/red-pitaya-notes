#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <unistd.h>
#include <stdlib.h>
#include <sys/mman.h>
#include <pthread.h>
#include <fcntl.h>
#include <signal.h>
#include <sys/types.h>
#include <sys/ioctl.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <errno.h>
#include "rp_hw-profiles.h"
#include "rp_hw-calib.h"

//#define RAM_START 0x0fff0000
#define RAM_START  0x10000000
#define RAM_LENGTH 0x10000000
#define READ_DATA  0x40010000
#define READ_SIZE  0x00004000
#define WRITE_DATA 0x40040000
#define WRITE_SIZE 0x0040000
#define MAX_SAMPLES 0x1FFFFFF

//#define RAM_START 0x1E000000
#define VISA_PORT 5000
#define TCP_PORT 1002
#define SYSTEM_CALL_MAX 2
#define UPDATE_CIC_FLAG 4
#define TRIGGER_RECORD_FLAG 8
#define RX_TX_RESET 16

// Configuration offsets
#define RECORD_LENGTH_OFFSET 4
#define FREQ_OFFSET 8
#define DESIMATION_OFFSET  12
#define DDS_DELAY  28

// Status offsets
#define RECORD_START_POS_OFFSET 4
#define WRITER_STS_OFFSET 0
#define FLAGS_ID_OFFSET 8
#define VALUE_OFFSET 16
#define RX_FIFO_CNT_OFFSET 24
#define TX_FIFO_CNT_OFFSET 28

// Commands
#define CMD_CONNECT 5
#define CMD_STOP 2
#define CMD_IDN 1

void *cfg, *ram, *sts, *hub;
void *rx_data,*tx_data;
int init_mem_map();
int clean_up();

int interrupted = 0;
void signal_handler(int sig);

int rx_thread_state = 0;
int tx_thread_state = 0;
int rx_thread_asc = 0;
int tx_thread_asc = 0;

double temperature_scale,temperature;
int temperature_raw, temperature_offset;
int init_temperature_scale();
int start_VISA();
int verbose=0,fscfrtn;

void *rx_handler(void *arg);
void *tx_handler(void *arg);
void *ctrl_handler(void *arg);

int sock_thread[3] = {-1, -1, -1};

static rp_calib_params_t calibration;
int read_calibration();

int main(int argc, char *argv[])
{
  int sockServer,sock_client,yes = 1;
  uint64_t command = 600000;
  pthread_t thread;
  uint32_t IDN=0xb00b;
  uint32_t status;
  void *(*handler[3])(void *) =
  {
    ctrl_handler,
	rx_handler,
	tx_handler
  };


  struct sockaddr_in addr;
  if (argc >=2 ) {
	  if (argv[1][0]=='v' ) verbose = 1;
	  if (argv[1][0]=='V' ) verbose = 2;
  }

  if(init_mem_map())
  {
    perror("memory mapping");
    return EXIT_FAILURE;
  }
  //put logic into reset
 *((uint32_t *)(cfg + 0)) &= ~0xf;

  if(init_temperature_scale())
 {
   perror("temperature scale");
   return EXIT_FAILURE;
 }

  if((sockServer = socket(AF_INET, SOCK_STREAM, 0)) < 0)
  {
    perror("socket");
    return EXIT_FAILURE;
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
    return EXIT_FAILURE;
  }

  listen(sockServer, 1024);
  signal(SIGINT, signal_handler);

  read_calibration(&calibration);

  while(!interrupted) {
	  int result, selector;
	  if(verbose)printf("MAIN: waiting for client\n");
	  if((sock_client = accept(sockServer, NULL, NULL)) < 0)
      {
          perror("accept");
          return 1;
      }
	  if(verbose)printf("MAIN: new connection, waiting for command\n");
	  result = recv(sock_client, (char *)&command, sizeof(command), MSG_WAITALL);
	  if(result >= sizeof(command) )
	  {
	     switch(command >> 60)
	     {
	       case CMD_IDN:
	    	  if(verbose)printf("MAIN: IDN query %d, socket=%d\n",CMD_IDN,sock_client);
	          status=*((uint32_t *)(sts + 8));
	          if(verbose)printf("Status = %u\n", status);
	          status = ( status & 0xffff0000 ) | (IDN & 0x0000ffff );
	 	  if(send(sock_client, &status, sizeof(status), 0) < 0){   perror("send");break;}
	    	  if(verbose)printf("Closing socket=%d\n",sock_client);
	 	  close(sock_client);
	    	  break;
	       case CMD_CONNECT:
		 selector = command & 0x3;
                 if(verbose)printf("MAIN: Connect command %d, selector = %d\n",CMD_CONNECT,selector);
	    	 if(selector<3)
	    	 {  
	    	   if(sock_thread[selector] > -1)
	    	   {
	    	      	int ret;
	    	       	if(verbose)printf("MAIN: closing old thread connection thread=%d, selector = %d\n",sock_thread[selector],selector);
	    	        ret=shutdown(sock_thread[selector],SHUT_RDWR);
	    	        while(sock_thread[selector] > -1) usleep(1000);
	    	        if(verbose)printf("MAIN: thread shutdown ret = %d, command = x%llx, now sock=%d, selector = %d\n",ret,command,sock_thread[selector],selector);
	    	   }
	   	       sock_thread[selector] = sock_client;
	    	   if(pthread_create(&thread, NULL, handler[selector], NULL) < 0)
	    	   {
	    		    perror("pthread_create");
	    		    return EXIT_FAILURE;
	    	   }
	    	   pthread_detach(thread);
	    	   if(verbose)printf("MAIN: Created and detached new thread = %d, selector = %d\n",sock_thread[selector],selector);
	    	 }
	    	 break;
	       case CMD_STOP:
	    	   close(sock_client);
	    	   clean_up();
	    	   if(verbose)printf("Exit program\n");
	    	   return 0;
	    	 break;
	       default:
			 if(verbose)printf("Unexpected command %d, closing connection, socket = %d\n",(int)(command >> 60),sock_client);
		     close(sock_client);
             break;
	     }
	  }
	  else
	  {
		 if(verbose)printf("Unexpected communication, closing connection, socket = %d\n",sock_client);
		 close(sock_client);
      }
	}
  clean_up();
  return 0;
}

void *ctrl_handler(void *arg)
{
	int sock_client = sock_thread[0];
	int stop=0,samples,i;
	uint64_t command;
	uint32_t selector,addr;
	ssize_t result,ret;
	off_t offset;
	uint32_t status, trigger_pos, start_offset, end_offset, config,packet_size=4096,tot, pre;
	FILE *fp;
	uint32_t IDN=0xdead;
	uint16_t mask;
	uint32_t buffer[WRITE_SIZE/4];
	volatile uint8_t *rst;
	rst = (uint8_t *)(cfg + 0);

	 // char *system_call[] ={"cat /root/d.bit > /dev/xdevcfg","cat /root/fd.bit > /dev/xdevcfg"};

	if(verbose)printf("CTRL THREAD started: !stop = %d, sock_client = %d\n", !stop,sock_client);
	while(!stop)
	{
		result = recv(sock_client, (char *)&command, sizeof(command), MSG_WAITALL);
		selector = command >> 60;
		if(verbose >1)printf("Thread: sock_client = %d, recv result = %d, command(u) = %llx, selector = %d\n", sock_client, result,command,selector);
	    if( result < sizeof(command)){if(verbose)printf("Recv less then expected %d bytes, breaking\n",sizeof(command)); break;}
	    switch(selector)
	    {  case 0:
	    	     mask = command & 0xFFFF;
	    	     if(verbose)printf("Sending reset. Mask %x\n",(uint32_t)mask);
	    	     /* Reset on*/
	    	     *((uint32_t *)(cfg + 0)) &= ~ mask;
	    	     usleep(1000);
	    	     /* Reset off */
	    	     *((uint32_t *)(cfg + 0)) |= mask;
	      break;
	      case CMD_IDN:
	    	   if(verbose)printf("CTRL: IDN query, socket=%d\n",sock_client);
	          	status=*((uint32_t *)(sts + 8));
	          	if(verbose>1)printf("Status = %u\n", status);
	          	status = ( status & 0xffff0000 ) | (IDN & 0x0000ffff );
	 		   if(send(sock_client, &status, sizeof(status), 0) < 0){   perror("send");break;}
	    	   break;
	      case CMD_STOP:
                    stop = 1;
                    if(verbose)printf("Command %d. Stopping CTRL thread,!stop = %d, sock_client = %d\n", selector,!stop,sock_client);
            break;
          case 3: //get status
          	offset = command & 0xFFFFFFFF;
		if(verbose>1)printf("Status inqury. ");
          	status=*((uint32_t *)(sts + offset));
          	if(verbose>1)printf("STS Offset =%u, Status = %u",(uint32_t)offset, status);
		if((ret=send(sock_client, sts + offset, sizeof(status), 0)) < 0){   perror("staus send");break;}
		if(verbose>1)printf("Status response: %d bytes sent.\n",ret);
          	break;
          case 4: //get temperature
          	if((fp = fopen("/sys/bus/iio/devices/iio:device0/in_temp0_raw", "r")) == NULL){
          	    perror("device open");
          		break;
          	}
          	ret=fscanf(fp,"%d", &temperature_raw);
          	fclose(fp);
          	temperature=temperature_scale/1000*(temperature_raw+temperature_offset);
           	if(send(sock_client, &temperature, sizeof(temperature), 0) < 0){   perror("send");break;}
          	break;
          case 6:  // arm
		tot = (command & (RAM_LENGTH-1))-1;
		pre = 	((command  >> 30)& (RAM_LENGTH-1));
           	 if(verbose)printf("Arm command 6. Samples = %d, Pre samples = %d\n", tot,pre);
           	if(verbose)printf("Pre-arm, writer %d, osciloscope %d, flags %d\n", *((uint32_t *)(sts + 0)),*((uint32_t *)(sts + 4)),*((uint16_t *)(sts + 8)));
                /*Software trig OFF
		*rst &= ~ 8;
		/* reset oscilloscope and ram writer */
		*rst &= ~1;
		*rst |= 1;
		/* set total number of samples (up to RAM_LENGTH/sample size) */
		if(verbose)printf("Samples = %d to cfg + %d\n", tot,RECORD_LENGTH_OFFSET);
		*(uint32_t *)(cfg + RECORD_LENGTH_OFFSET) = tot;
		if(verbose)printf("Pre samples = %d to cfg + %d\n", pre,52);
		*(uint32_t *)(cfg + 52) = pre;
		if(verbose)printf("Staring osciloscope\n");

                   /* start oscilloscope */
                   *rst |= 2;
                   *rst &= ~2;

           	if(verbose){printf("Armed, cfg %d,writer %d, osciloscope %d, flags %d\n", *(uint8_t *)(cfg + 0),*((uint32_t *)(sts + 0)),*((uint32_t *)(sts + 4)),*((uint16_t *)(sts + 8)));}
           	break;
          case 7: //software trigger
              //trigger
               if(verbose)printf("Software trigger command 7, writer %d,  osciloscope %d, flags %d\n",*((uint32_t *)(sts + 0)),*((uint32_t *)(sts + 4)),*((uint16_t *)(sts + 8)));
               *rst |= 8;
		usleep(10);
               *rst &= ~ 8;
               if(verbose)printf(" After trigger, cfg %d,  writer %d,  osciloscope %d, flags %d\n",*((uint32_t *)(cfg + 0)),*((uint32_t *)(sts + 0)),*((uint32_t *)(sts + 4)),*((uint16_t *)(sts + 8)));
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
        		 if(send(sock_client, ram + offset, packet_size, 0) < 0){   perror("send");break;}
        	 	 if(verbose > 1) if((offset)%(packet_size*256)==0)printf("Offset %ld\n",offset);
        	}
            if(verbose)printf("Offset %ld\n",offset);
        	config=*((uint32_t *)(cfg + 0));
        	if(verbose)printf("Start pos = %d, Last offset = %ld, Start off = %d, end off = %d, writer sts = %d, config = %x\n",trigger_pos,offset, start_offset, end_offset,*((uint32_t *)(sts + WRITER_STS_OFFSET)),config);
            break;
          case 9: //read data chunk
          	start_offset= command & (RAM_LENGTH-1);
                tot = (command  >> 30)& (RAM_LENGTH-1);
          	end_offset = (command  >> 30)& 0x3FFFFFFF;
       		trigger_pos=*((uint32_t *)(sts + RECORD_START_POS_OFFSET));
       		if(verbose) {
		   uint32_t start,pre_samples,tot_samples;
                   printf("Command 9: read data chunk\n");
                  if(verbose)printf("Writer %d,  osciloscope %d, flags %d\n",*((uint32_t *)(sts + 0)),*((uint32_t *)(sts + 4)),*((uint16_t *)(sts + 8)));
                   start = *(uint32_t *)(sts + 4) >> 1;
                   printf("Trigger position %d\n",start);
                   pre_samples = *(uint32_t *)(cfg + 52);
                   tot_samples =  *(uint32_t *)(cfg + 16);
                   printf("Trigger position minus pre, warped %d. Start+tot %d, max %d\n",start-pre_samples,start+-pre_samples+tot_samples,MAX_SAMPLES );
                   printf("Sending data, start = %d, end = %d, trigger pos = %d\n", start_offset,end_offset,trigger_pos);
                }
                if(start_offset+tot <= (RAM_LENGTH-1))
		{
			  if(send(sock_client, ram + start_offset, tot, MSG_NOSIGNAL) < 0) break;
			  if(verbose)printf("Sent one chunk: %d bytes starting from %d\n", tot, start_offset);
		}
                else
		{ 
			  if(send(sock_client, ram + start_offset, ((RAM_LENGTH) - start_offset), MSG_NOSIGNAL) < 0) break;
			  if(send(sock_client, ram, (start_offset + tot - (RAM_LENGTH)), MSG_NOSIGNAL) < 0) break;
	                  if(verbose)printf("Sent two chunks: %d bytes starting from %d, then %d bytes starting from %d\n", ((RAM_LENGTH-1) - start_offset), start_offset, (start_offset + tot - (RAM_LENGTH-1)),0);
		}
 
        	if(verbose)printf("Last offset %ld\n",offset);
        	config=*((uint32_t *)(cfg + 0));
        	if(verbose)printf("writer sts = %d, config = %x\n",*((uint32_t *)(sts + 0)),config);
            break;
          case 11: //get config
          	 offset = command & 0xFFFFFFFF;
          	 status=*((uint32_t *)(cfg + offset));
          	 if(verbose > 1)printf("CFG Offset =%u, Status = %u\n",(uint32_t)offset, status);
 	         if(send(sock_client, cfg + offset, sizeof(status), 0) < 0){   perror("send");break;}
          	 break;
          case 12: //set config
          	offset = (command >> 32)& 0xFF;
          	status=command & 0xFFFFFFFF;
          	if(verbose)printf("Set CFG Offset =%u, State = %u\n",(uint32_t)offset, status);
          	*((uint32_t *)(cfg + offset)) = status;
 			break;
          case 13: // read from hub
           	samples = command >> 28 & 0xffffff;
                addr = command & 0xfffffff;
          	if(verbose>1)printf("Read %d u32. FIFO Counter =%u\n",samples,*((uint32_t *)(sts + RX_FIFO_CNT_OFFSET)));
          	//while(*((uint32_t *)(sts + RX_FIFO_CNT_OFFSET))< 4096)usleep(500);
          	//memcpy(buffer, rx_data, samples);
          	for(i = 0; i < samples; ++i) buffer[i] = *((uint32_t *)(hub+addr));
          	if(verbose>1)printf("After read FIFO. Counter =%u\n",*((uint32_t *)(sts + RX_FIFO_CNT_OFFSET)));
              if(send(sock_client, buffer, samples*4, MSG_NOSIGNAL) < 0){   perror("send FIFO");break;}
          	if(verbose){
          		printf("First words in RX buffer=");
                      		for (int i=0;i<15;++i)
                      			printf("%d, ",buffer[i] );
                  printf("\n");
          	}
              break;

          case 14: //read-write calibration
		  switch(command & 0x3) {
		    case 0:
		         if(verbose)printf("Read calibration. Sending %d bytes\n",sizeof(calibration));
        	         if(send(sock_client, &calibration, sizeof(calibration), 0) < 0){   perror("send");break;}
		         break;
		    case 1:
			if(verbose)printf("Write calibration. Receiving %d bytes\n",sizeof(calibration));
			if(recv(sock_client, &calibration, sizeof(calibration), MSG_WAITALL) < 0) { perror("rec calibration");break;}	
			if(verbose) for (int i = 0; i<calibration.fast_adc_count_1_1;i++) 
			{
				printf("IN%d 1V scale = %f, value = %d, offset = %d, gain = %f\n",i,calibration.fast_adc_1_1[i].baseScale,calibration.fast_adc_1_1[i].calibValue,calibration.fast_adc_1_1[i].offset,calibration.fast_adc_1_1[i].gainCalc);
				printf("IN%d Filter aa = %d, bb = %d, pp= %d, kk = %d\n",i,calibration.fast_adc_filter_1_1[i].aa,calibration.fast_adc_filter_1_1[i].bb,calibration.fast_adc_filter_1_1[i].pp,calibration.fast_adc_filter_1_1[i].kk);
			}
			rp_CalibrationWriteParams(calibration,false);			
		        break;
		    case 2:
			if(verbose)printf("Reset to factory calibration\n");
			rp_CalibrationFactoryReset(true);
                        // rp_CalibInit();
                        calibration = rp_GetCalibrationSettings();
			break;
		}
                break;
          case 15: //Write to hub
           	samples = command >> 28 & 0xffffff;
                addr = command & 0xfffffff;
           	if(verbose)printf("Writing %d u32 words to hub address %x\n",samples, addr+ 0x40000000);
           	if(recv(sock_client, buffer, samples*4, MSG_WAITALL) < 0) break;
          	for(i = 0; i < samples; ++i) ((uint32_t *)(hub+addr))[i]=buffer[i];
          	//memcpy( tx_data, buffer,samples);
          	if(verbose){
          		printf("First words in TX buffer=");
                      		for (int i=0;i<31;++i)
                      			printf("%d, ",buffer[i] );
                  printf("\n");
          	}
              break;
	      default:
				
			 if(verbose)printf("Unexpected command %d  in control loop, payload %llu, socket = %d\n",selector, command,sock_client);
             break;
	    }
	}
	if(verbose)printf("Stopping CTRL thread, sock_client=%d, recv result = %d\n",sock_client,result);
	close(sock_client);
	sock_thread[0] = -1;
	return NULL;
}


void *rx_handler(void *arg)
{
	int sock_client = sock_thread[1];
	int stop=0,samples;
	uint64_t command;
	uint32_t selector;
	ssize_t result;
	off_t offset;
	uint32_t status;
	char buffer[READ_SIZE];
	uint32_t IDN=0xbaba;

	if(verbose)printf("RX THREAD started: !stop = %d, sock_client = %d\n", !stop,sock_client);
	while(!stop)
	{
		result = recv(sock_client, (char *)&command, sizeof(command), MSG_WAITALL);
		selector = command >> 60;
		if(verbose)printf("Thread: sock_client = %d, recv result = %d, command(u) = %llx, selector = %d\n", sock_client, result,command,selector);
	    if( result < sizeof(command)) break;
	    switch(selector)
	    {
	         case CMD_IDN:
	    	   if(verbose)printf("RX: IDN query, socket=%d\n",sock_client);
	          	status=*((uint32_t *)(sts + 8));
	          	if(verbose>1)printf("Status = %u\n", status);
	 		   if(send(sock_client, &status, sizeof(status), 0) < 0){   perror("send");break;}
	    	   break;
	      case CMD_STOP:
            stop = 1;
            if(verbose)printf("Stopping CTRL thread,!stop = %d, sock_client = %d\n", !stop,sock_client);
            break;
          case 3: //get status
          	offset = command & 0xFFFFFFFF;
          	status=*((uint32_t *)(sts + offset));
          	if(verbose>1)printf("STS Offset =%u, Status = %u\n",(uint32_t)offset, status);
 			if(send(sock_client, sts + offset, sizeof(status), 0) < 0){   perror("send");break;}
          	break;
          case 12: //set config
          	offset = (command >> 32)& 0xFF;
          	status=command & 0xFFFFFFFF;
          	if(verbose)printf("Set CFG Offset =%u, State = %u\n",(uint32_t)offset, status);
          	*((uint32_t *)(cfg + offset)) = status;
 			break;
          case 13: // read RX BUFFER
          	samples = command & 0xFFFFFFFF;
          	if(verbose>1)printf("Read %d samples RX buffer. Counter =%u\n",samples,*((uint32_t *)(sts + RX_FIFO_CNT_OFFSET)));
          	//while(*((uint32_t *)(sts + RX_FIFO_CNT_OFFSET))< 4096)usleep(500);
          	memcpy(buffer, rx_data, samples);
          	//if(verbose>1)printf("After read FIFO. Counter =%u\n",*((uint32_t *)(sts + RX_FIFO_CNT_OFFSET)));
            if(send(sock_client, buffer, samples, MSG_NOSIGNAL) < 0){   perror("send RX");break;}
            break;
          case 14: //read calibration
        	  if(send(sock_client, &calibration, sizeof(calibration), 0) < 0){   perror("send");break;}
              		break;
	    }
	}
	if(verbose)printf("Stopping RX thread, sock_client=%d, recv result = %d\n",sock_client,result);
	close(sock_client);
	sock_thread[1] = -1;
	return NULL;
}

void *tx_handler(void *arg)
{
	int sock_client = sock_thread[2];
	int stop=0,samples;
	uint64_t command;
	uint32_t selector;
	ssize_t result;
	off_t offset;
	uint32_t status;
	char buffer[0x10000];
	uint32_t IDN=0xdeda;

	if(verbose)printf("RX THREAD started: !stop = %d, sock_client = %d\n", !stop,sock_client);
	while(!stop)
	{
		result = recv(sock_client, (char *)&command, sizeof(command), MSG_WAITALL);
		selector = command >> 60;
		if(verbose)printf("Thread: sock_client = %d, recv result = %d, command(u) = %llx, selector = %d\n", sock_client, result,command,selector);
	    if( result < sizeof(command)) break;
	    switch(selector)
	    {
        case CMD_IDN:
   	        if(verbose)printf("TX: IDN query, socket=%d\n",sock_client);
         	status=*((uint32_t *)(sts + 8));
          	if(verbose>1)printf("Status = %u\n", status);
		    if(send(sock_client, &status, sizeof(status), 0) < 0){   perror("send");break;}
   	     break;
	      case CMD_STOP:
            stop = 1;
            if(verbose)printf("Stopping CTRL thread,!stop = %d, sock_client = %d\n", !stop,sock_client);
            break;
          case 3: //get status
          	offset = command & 0xFFFFFFFF;
          	status=*((uint32_t *)(sts + offset));
          	if(verbose>1)printf("STS Offset =%u, Status = %u\n",(uint32_t)offset, status);
 			if(send(sock_client, sts + offset, sizeof(status), 0) < 0){   perror("send");break;}
          	break;
          case 12: //set config
          	offset = (command >> 32)& 0xFF;
          	status=command & 0xFFFFFFFF;
          	if(verbose)printf("Set CFG Offset =%u, State = %u\n",(uint32_t)offset, status);
          	*((uint32_t *)(cfg + offset)) = status;
 			break;
          case 14: //read calibration
        	  if(send(sock_client, &calibration, sizeof(calibration), 0) < 0){   perror("send");break;}
              		break;
          case 15: //Transmit a block
          	samples = command & 0xFFFFFFFF;
          	if(verbose)printf("Transmitting %d bytes\n",samples);
          	if(recv(sock_client, buffer, samples, MSG_WAITALL) < 0) break;
          	if(verbose)printf("1st 32-bit word %d\n",*(uint32_t *)buffer);
          	memcpy( tx_data, buffer,samples);
            break;
	    }
	}
	if(verbose)printf("Stopping RX thread, sock_client=%d, recv result = %d\n",sock_client,result);
	close(sock_client);
	sock_thread[2] = -1;
	return NULL;
}




int init_temperature_scale()
{
	FILE *fp;
	if((fp = fopen("/sys/bus/iio/devices/iio:device0/in_temp0_offset", "r")) == NULL){
		perror("device open");
		return 1;
	}
	fscfrtn=fscanf(fp,"%d", &temperature_offset);
	fclose(fp);
	if((fp = fopen("/sys/bus/iio/devices/iio:device0/in_temp0_scale", "r")) == NULL){
	    perror("device open");
	    return 1;
	}
	fscfrtn=fscanf(fp,"%lf", &temperature_scale);
	fclose(fp);
	if((fp = fopen("/sys/bus/iio/devices/iio:device0/in_temp0_raw", "r")) == NULL){
	    perror("device open");
	    return 1;
	}
	fscfrtn=fscanf(fp,"%d", &temperature_raw);
	fclose(fp);
	temperature=temperature_scale/1000*(temperature_raw+temperature_offset);
	if(verbose)printf("Temperature scale = %lf, offset = %d, raw = %d\nTemperature = %lf\n", temperature_scale, temperature_offset, temperature_raw, temperature);
    return 0;
}

int init_mem_map()
{
	int fd;
	if((fd = open("/dev/mem", O_RDWR)) < 0)
	  {
	    perror("open mem");
	    return EXIT_FAILURE;
	  }
  	cfg = mmap(NULL, sysconf(_SC_PAGESIZE), PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0x40000000);
	sts = mmap(NULL, sysconf(_SC_PAGESIZE), PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0x41000000);
	hub = mmap(NULL, 32768*sysconf(_SC_PAGESIZE), PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0x40000000);
	ram = mmap(NULL,RAM_LENGTH , PROT_READ|PROT_WRITE, MAP_SHARED, fd, RAM_START);
	tx_data = rx_data = mmap(NULL, 32*sysconf(_SC_PAGESIZE), PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0x42000000);
        close(fd);
	return EXIT_SUCCESS;
}

void signal_handler(int sig)
{
  interrupted = 1;
}

int clean_up()
{
	  munmap(cfg, sysconf(_SC_PAGESIZE));
	  munmap(ram, sysconf(_SC_PAGESIZE));
	  munmap(sts, sysconf(_SC_PAGESIZE));
	  munmap(rx_data, sysconf(_SC_PAGESIZE));
	  munmap(tx_data, sysconf(_SC_PAGESIZE));
	  return 0;
}
int read_calibration()
{
    rp_HPeModels_t model;
    rp_CalibInit();
    calibration = rp_GetCalibrationSettings();
    rp_HPGetModel(&model);
    if(verbose>1) {
         rp_HPPrint();
    }
    if(verbose) {
	printf("Model = %d\n",model);
	printf("Sizes: rp_calib_params_t = %d, channel_calib_t = %d, channel_filter_t = %d, float = %d, double = %d\n",sizeof(rp_calib_params_t),sizeof(channel_calib_t),sizeof(channel_filter_t),sizeof(float),sizeof(double));
	printf("Calibration parameters:\n ID = %d, wpCheck = %d, adc count 1V  = %d, adc count 20V  = %d, dac count = %d\n",calibration.dataStructureId,calibration.wpCheck,calibration.fast_adc_count_1_1,calibration.fast_adc_count_1_20,calibration.fast_dac_count_x1);
	for (int i = 0; i<calibration.fast_adc_count_1_1;i++) 
	{
		printf("IN%d 1V scale = %f, value = %d, offset = %d, gain = %f\n",i,calibration.fast_adc_1_1[i].baseScale,calibration.fast_adc_1_1[i].calibValue,calibration.fast_adc_1_1[i].offset,calibration.fast_adc_1_1[i].gainCalc);
		printf("IN%d Filter aa = %d, bb = %d, pp= %d, kk = %d\n",i,calibration.fast_adc_filter_1_1[i].aa,calibration.fast_adc_filter_1_1[i].bb,calibration.fast_adc_filter_1_1[i].pp,calibration.fast_adc_filter_1_1[i].kk);

	}

	for (int i = 0; i<calibration.fast_adc_count_1_20;i++) 
	{
		printf("IN%d 20V scale = %f, value = %d, offset = %d, gain = %f\n",i,calibration.fast_adc_1_20[i].baseScale,calibration.fast_adc_1_20[i].calibValue,calibration.fast_adc_1_20[i].offset,calibration.fast_adc_1_20[i].gainCalc);
	}
	for (int i = 0; i<calibration.fast_dac_count_x1;i++) 
	{
		printf("OUT%d 1V scale = %f, value = %d, offset = %d, gain = %f\n",i,calibration.fast_dac_x1[i].baseScale,calibration.fast_dac_x1[i].calibValue,calibration.fast_dac_x1[i].offset,calibration.fast_dac_x1[i].gainCalc);
	}
   }
   return 0;
}
