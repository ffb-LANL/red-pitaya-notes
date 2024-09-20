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

//#define RAM_START 0x0fff0000
#define RAM_LENGTH 0x10000000
#define READ_DATA  0x40010000
#define READ_SIZE  0x00004000
#define WRITE_DATA 0x40040000
#define WRITE_SIZE 0x0040000


#define CMA_ALLOC _IOWR('Z', 0, uint32_t)

//#define RAM_START 0x1E000000
#define TCP_PORT 1002
#define SYSTEM_CALL_MAX 2
#define PKTZR_RESET_FLAG 1
#define WRITER_ENABLE_FLAG 2
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

void *cfg, *ram, *sts;
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
int verbose=0;

void *rx_handler(void *arg);
void *tx_handler(void *arg);
void *ctrl_handler(void *arg);

int sock_thread[3] = {-1, -1, -1};

/**
 * Calibration parameters, stored in the EEPROM device
 */
typedef struct {
    uint32_t fe_ch1_fs_g_hi; //!< High gain front end full scale voltage, channel A
    uint32_t fe_ch2_fs_g_hi; //!< High gain front end full scale voltage, channel B
    uint32_t fe_ch1_fs_g_lo; //!< Low gain front end full scale voltage, channel A
    uint32_t fe_ch2_fs_g_lo; //!< Low gain front end full scale voltage, channel B
    int32_t  fe_ch1_lo_offs; //!< Front end DC offset, channel A
    int32_t  fe_ch2_lo_offs; //!< Front end DC offset, channel B
    uint32_t be_ch1_fs;      //!< Back end full scale voltage, channel A
    uint32_t be_ch2_fs;      //!< Back end full scale voltage, channel B
    int32_t  be_ch1_dc_offs; //!< Back end DC offset, channel A
    int32_t  be_ch2_dc_offs; //!< Back end DC offset, on channel B
	uint32_t magic;			 //!
    int32_t  fe_ch1_hi_offs; //!< Front end DC offset, channel A
    int32_t  fe_ch2_hi_offs; //!< Front end DC offset, channel B
} rp_calib_params_t;

rp_calib_params_t calibration;
int read_calibration(rp_calib_params_t *context);

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
  if(verbose)printf("MAIN: Starting\n");

  if(test_cma())
  {
    perror("memory mapping");
    return EXIT_FAILURE;
  }

  if(verbose)printf("MAIN: Finished\n");
  return EXIT_SUCCESS;

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
	  if(verbose)printf("waiting for client\n");
	  if((sock_client = accept(sockServer, NULL, NULL)) < 0)
      {
          perror("accept");
          return 1;
      }
	  if(verbose)printf("new connection, waiting for command\n");
	  result = recv(sock_client, (char *)&command, sizeof(command), MSG_WAITALL);
	  if(result >= sizeof(command) )
	  {
	     switch(command >> 60)
	     {
	       case CMD_IDN:
	    	   if(verbose)printf("MAIN: IDN query, socket=%d\n",sock_client);
	          	status=*((uint32_t *)(sts + 8));
	          	if(verbose)printf("Status = %u\n", status);
	          	status = ( status & 0xffff0000 ) | (IDN & 0x0000ffff );
	 		   if(send(sock_client, &status, sizeof(status), 0) < 0){   perror("send");break;}
	 		   close(sock_client);
	    	   break;
	       case CMD_CONNECT:
	    	 if((selector = command & 0x3)<3)
	    	 {
	    	   if(sock_thread[selector] > -1)
	    	   {
	    	      	int ret;
	    	       	if(verbose)printf("MAIN: closing thread connection sock=%d\n",sock_thread[selector]);
	    	        ret=shutdown(sock_thread[selector],SHUT_RDWR);
	    	        while(sock_thread[selector] > -1) usleep(1000);
	    	        if(verbose)printf("MAIN: shutdown ret = %d, command = %llx, now sock=%d\n",ret,command,sock_thread[selector]);
	    	   }
	   	       sock_thread[selector] = sock_client;
	    	   if(pthread_create(&thread, NULL, handler[selector], NULL) < 0)
	    	   {
	    		    perror("pthread_create");
	    		    return EXIT_FAILURE;
	    	   }
	    	   pthread_detach(thread);
	    	 }
	    	 break;
	       case CMD_STOP:
	    	   close(sock_client);
	    	   clean_up();
	    	   if(verbose)printf("Exit program\n");
	    	   return 0;
	    	 break;
	       default:
			 if(verbose)printf("Unexpected command, closing connection, socket = %d\n",sock_client);
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
	uint32_t selector;
	ssize_t result;
	off_t offset;
	uint32_t status, trigger_pos, start_offset, end_offset, config,packet_size=4096;
	FILE *fp;
	uint32_t IDN=0xdead;
	uint16_t mask;
	uint32_t buffer[WRITE_SIZE/4];
	 // char *system_call[] ={"cat /root/d.bit > /dev/xdevcfg","cat /root/fd.bit > /dev/xdevcfg"};

	if(verbose)printf("CTRL THREAD started: !stop = %d, sock_client = %d\n", !stop,sock_client);
	while(!stop)
	{
		result = recv(sock_client, (char *)&command, sizeof(command), MSG_WAITALL);
		selector = command >> 60;
		if(verbose)printf("Thread: sock_client = %d, recv result = %d, command(u) = %llx, selector = %d\n", sock_client, result,command,selector);
	    if( result < sizeof(command)) break;
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
            if(verbose)printf("Stopping CTRL thread,!stop = %d, sock_client = %d\n", !stop,sock_client);
            break;
          case 3: //get status
          	offset = command & 0xFFFFFFFF;
          	status=*((uint32_t *)(sts + offset));
          	if(verbose>1)printf("STS Offset =%u, Status = %u\n",(uint32_t)offset, status);
 			if(send(sock_client, sts + offset, sizeof(status), 0) < 0){   perror("send");break;}
          	break;
          case 4: //get temperature
          	if((fp = fopen("/sys/bus/iio/devices/iio:device0/in_temp0_raw", "r")) == NULL){
          	    perror("device open");
          		break;
          	}
          	fscanf(fp,"%d", &temperature_raw);
          	fclose(fp);
          	temperature=temperature_scale/1000*(temperature_raw+temperature_offset);
           	if(send(sock_client, &temperature, sizeof(temperature), 0) < 0){   perror("send");break;}
          	break;
          case 6:  // arm
           	samples = command & 0xFFFFFFFF;
           	// reset writer and packetizer
           	  *((uint32_t *)(cfg + 0)) &= ~ ( WRITER_ENABLE_FLAG | PKTZR_RESET_FLAG | TRIGGER_RECORD_FLAG) ;
           	  // set number of samples
           	  *((uint32_t *)(cfg + RECORD_LENGTH_OFFSET)) = samples;
           	 if(verbose)printf("Entering normal mode. Samples = %d\n", samples);

           	  // enter normal mode
           	 *((uint32_t *)(cfg + 0)) |= ( WRITER_ENABLE_FLAG | PKTZR_RESET_FLAG );
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
        		 if(send(sock_client, ram + offset, packet_size, 0) < 0){   perror("send");break;}
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
        		 if(send(sock_client, ram + offset, packet_size, 0) < 0){   perror("send");break;}
        		 if(verbose > 1) if((offset-start_offset)%(packet_size*128)==0)printf("Offset %d\n",offset);
        	}
        	if(verbose)printf("Last offset %d\n",offset);
        	config=*((uint32_t *)(cfg + 0));
        	if(verbose)printf("writer sts = %d, config = %x\n",*((uint32_t *)(sts + WRITER_STS_OFFSET)),config);
            break;
          case 11: //get config
          	 offset = command & 0xFFFFFFFF;
          	 status=*((uint32_t *)(cfg + offset));
          	 if(verbose)printf("CFG Offset =%u, Status = %u\n",(uint32_t)offset, status);
 			 if(send(sock_client, cfg + offset, sizeof(status), 0) < 0){   perror("send");break;}
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
              if(send(sock_client, buffer, samples*4, MSG_NOSIGNAL) < 0){   perror("send FIFO");break;}
          	if(verbose){
          		printf("First words in RX buffer=");
                      		for (int i=0;i<15;++i)
                      			printf("%d, ",buffer[i] );
                  printf("\n");
          	}
              break;

          case 14: //read calibration
        	  if(send(sock_client, &calibration, sizeof(calibration), 0) < 0){   perror("send");break;}
              		break;
          case 15: //Write TX FIFO
           	samples = command & 0xFFFFFFFF;
           	if(verbose)printf("Writing %d u32 words\n",samples);
           	if(recv(sock_client, buffer, samples*4, MSG_WAITALL) < 0) break;
          	for(i = 0; i < samples; ++i) ((uint32_t *)tx_data)[i]=buffer[i];
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
	fscanf(fp,"%d", &temperature_offset);
	fclose(fp);
	if((fp = fopen("/sys/bus/iio/devices/iio:device0/in_temp0_scale", "r")) == NULL){
	    perror("device open");
	    return 1;
	}
	fscanf(fp,"%lf", &temperature_scale);
	fclose(fp);
	if((fp = fopen("/sys/bus/iio/devices/iio:device0/in_temp0_raw", "r")) == NULL){
	    perror("device open");
	    return 1;
	}
	fscanf(fp,"%d", &temperature_raw);
	fclose(fp);
	temperature=temperature_scale/1000*(temperature_raw+temperature_offset);
	if(verbose)printf("Temperature scale = %lf, offset = %d, raw = %d\nTemperature = %lf\n", temperature_scale, temperature_offset, temperature_raw, temperature);
    return 0;
}

int init_mem_map()
{
	volatile uint8_t *rst;
	uint32_t size;
	int fd;

	if(verbose)printf("init_mem_map: oppening dev mem\n");

	if((fd = open("/dev/mem", O_RDWR)) < 0)
	  {
	    perror("open mem");
	    return 1;
	  }
	if(verbose)printf("init_mem_map: mapping cfg sts\n");
  	cfg = mmap(NULL, sysconf(_SC_PAGESIZE), PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0x40000000);
	sts = mmap(NULL, sysconf(_SC_PAGESIZE), PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0x41000000);
	// if(verbose)printf("init_mem_map: mapping rx tx\n");

	// rx_data = mmap(NULL, 64*sysconf(_SC_PAGESIZE), PROT_READ|PROT_WRITE, MAP_SHARED, fd, READ_DATA);
	// tx_data = mmap(NULL, WRITE_SIZE, PROT_READ|PROT_WRITE, MAP_SHARED, fd, WRITE_DATA);

	close(fd);
	if(verbose)printf("init_mem_map: oppening CMA\n");

	if((fd = open("/dev/cma", O_RDWR)) < 0)
  	{
		perror("open cma");
		return 1;
  	}

  	size = 8192*sysconf(_SC_PAGESIZE);

	if(verbose)printf("init_mem_map: allocating CMA ram. Size = %u\n",size);  

  	if(ioctl(fd, CMA_ALLOC, &size) < 0)
  	{
    		perror("ioctl");
    		return 1;
  	}

	
	if(verbose)printf("init_mem_map: mapping ram. Size = %u\n",size);  

  	ram = mmap(NULL, 8192*sysconf(_SC_PAGESIZE), PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0);
	
	if(verbose)printf("init_mem_map: resetting writer\n");  	

	rst = (uint8_t *)(cfg + 0);

	/* set writer address */

	if(verbose)printf("init_mem_map: setting writer address\n"); 

  	*(uint32_t *)(cfg + 50) = size;

	/* reset oscilloscope and ram writer */
  	*rst &= ~1;
  	*rst |= 1;

	if(verbose)printf("init_mem_map: exiting\n"); 

	return 0;
}

int test_cma()
{
	volatile uint8_t *rst;
	volatile void *cfg, *sts, *ram;
	uint32_t size;
	int fd;

	if(verbose)printf("test_cma: oppening dev mem\n");

	if((fd = open("/dev/mem", O_RDWR)) < 0)
	  {
	    perror("open mem");
	    return 1;
	  }
	if(verbose)printf("test_cma: mapping cfg sts\n");
  	cfg = mmap(NULL, sysconf(_SC_PAGESIZE), PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0x40000000);
	sts = mmap(NULL, sysconf(_SC_PAGESIZE), PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0x41000000);

	close(fd);

	if(verbose)printf("test_cma: oppening CMA\n");

	if((fd = open("/dev/cma", O_RDWR)) < 0)
  	{
		perror("open cma");
		return 1;
  	}

  	size = 16*sysconf(_SC_PAGESIZE);


	if(verbose)printf("test_cma: allocating CMA ram. Size = %u\n",size);  

  	if(ioctl(fd, CMA_ALLOC, &size) < 0)
  	{
    		perror("ioctl");
    		return 1;
  	}

	
	if(verbose)printf("test_cma: mapping ram. Size = %u\n",size);  

  	ram = mmap(NULL, 16*sysconf(_SC_PAGESIZE), PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0);
	
	if(verbose)printf("test_cma: resetting writer\n");  	

	rst = (uint8_t *)(cfg + 0);

	/* set writer address */

	if(verbose)printf("init_mem_map: setting writer address\n"); 

  	*(uint32_t *)(cfg + 50) = size;

	/* reset oscilloscope and ram writer */
  	*rst &= ~1;
  	*rst |= 1;

	if(verbose)printf("init_mem_map: exiting\n"); 

	return 0;
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
int read_calibration(rp_calib_params_t * calib_params)
{
    int    fp;
    size_t size;


    /* open EEPROM device */
    fp = open("/sys/bus/i2c/devices/0-0050/eeprom", O_RDONLY); if (!fp) {
        return 1;
    }
    /* ...and seek to the appropriate storage offset */
    if (lseek(fp,0x0008, SEEK_SET) < 0) {
        close(fp);
        return 1;
    }
    /* read data from EEPROM component and store it to the specified buffer */
    size = read(fp,  calib_params, sizeof(rp_calib_params_t));
    if (size != sizeof(rp_calib_params_t)) {
        close(fp);
        return 1;
    }
    close(fp);
    if(verbose) {
       	printf("Read calibration\nmagic %x\nfe_ch1_fs_g_hi %d\nfe_ch2_fs_g_hi %d\nfe_ch1_fs_g_lo %d\nfe_ch2_fs_g_lo %d\nfe_ch1_lo_offs %d\nfe_ch2_lo_offs %d\nfe_ch1_hi_offs %d\nfe_ch2_hi_offs %d\nbe_ch1_fs %d\nbe_ch2_fs %d\nbe_ch1_dc_offs %d\nbe_ch2_dc_offs %d\n",
       			calib_params->magic, calib_params->fe_ch1_fs_g_hi,calib_params->fe_ch2_fs_g_hi,calib_params->fe_ch1_fs_g_lo,calib_params->fe_ch2_fs_g_lo,
			    calib_params->fe_ch1_lo_offs ,
			    calib_params->fe_ch2_lo_offs,
			    calib_params->fe_ch1_hi_offs,
			    calib_params->fe_ch2_hi_offs,
			    calib_params->be_ch1_fs,
			    calib_params->be_ch2_fs ,
			    calib_params->be_ch1_dc_offs ,
			    calib_params->be_ch2_dc_offs
       	); }
	  return 0;
}
