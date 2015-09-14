#include <stdio.h>
#include <stdint.h>
#include <unistd.h>
#include <sys/mman.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/ioctl.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#define RAM_START 0x8000000
#define TCP_PORT 1002
/* @brief Number of ADC acquisition bits.  */
const int                  c_osc_fpga_adc_bits = 14;
float osc_fpga_cnv_cnt_to_v(int cnts, float adc_max_v,
                            int calib_dc_off, float user_dc_off)
{
    int m;
    float ret_val;

    /* check sign */
    if(cnts & (1<<(c_osc_fpga_adc_bits-1))) {
        /* negative number */
        m = -1 *((cnts ^ ((1<<c_osc_fpga_adc_bits)-1)) + 1);
    } else {
        /* positive number */
        m = cnts;
    }

    /* adopt ADC count with calibrated DC offset */
    m += calib_dc_off;

    /* map ADC counts into user units */
    if(m < (-1 * (1<<(c_osc_fpga_adc_bits-1))))
        m = (-1 * (1<<(c_osc_fpga_adc_bits-1)));
    else if(m > (1<<(c_osc_fpga_adc_bits-1)))
        m =  (1<<(c_osc_fpga_adc_bits-1));

    ret_val =  (m * adc_max_v /
                (float)(1<<(c_osc_fpga_adc_bits-1)));

    /* and adopt the calculation with user specified DC offset */
    ret_val += user_dc_off;

    return ret_val;
}
int interrupted = 0;
int main()
{
  int fd, i, sockServer,sockClient,yes = 1,samples,packet_size=4096;
  unsigned long size = 0;
  int16_t value;
  uint64_t command = 600000;
  void *cfg, *ram;
  char *name = "/dev/mem";
  struct sockaddr_in addr;
  size_t length;
  off_t offset=0x8000000;
  samples = 0x18000 * 1024 - 1;
  if((fd = open(name, O_RDWR)) < 0)
  {
    perror("open");
    return 1;
  }
  length=(samples+1)*4;
  cfg = mmap(NULL, sysconf(_SC_PAGESIZE), PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0x40000000);
  ram = mmap(NULL,length , PROT_READ|PROT_WRITE, MAP_SHARED, fd, RAM_START);

  // reset writer
  *((uint32_t *)(cfg + 0)) &= ~2;
  *((uint32_t *)(cfg + 0)) |= 2;

  // enter reset mode for packetizer and fifo
  *((uint32_t *)(cfg + 0)) &= ~5;


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
            	// reset writer
            	samples = command & 0xFFFFFFFF;
         		  *((uint32_t *)(cfg + 0)) &= ~2;
         		  *((uint32_t *)(cfg + 0)) |= 2;

         		  // enter reset mode for packetizer and fifo
         		  *((uint32_t *)(cfg + 0)) &= ~5;

            	  // set number of samples
            	  *((uint32_t *)(cfg + 4)) = samples;
            	  printf("Entering normal mode. Samples = %d, buffer length = %d bytes\n", samples, length);
            	  // enter normal mode
            	  *((uint32_t *)(cfg + 0)) |= 5;
            	  // wait 1 second
            	  sleep(1);
           		 printf("Sending data\n");
           		 for(offset=0;offset < samples*4;offset +=packet_size)
           		 	 {
           			 	 if(send(sockClient, ram + offset, packet_size, 0) < 0){   perror("send");break;}
           			 	 //printf("%d\r",offset);
           		 	 }
           		 printf("Last offset = %d\n",offset);
           		// print IN2 samples
           		  for(i = 0; i < 20; ++i)
           		  {
           		    value = *((int16_t *)(ram + 4*i + 2));
           		    printf("%d\t%f\t%f\n", value,osc_fpga_cnv_cnt_to_v(value,1,0,0),(float)value/(float)0x2000);
           		  }
           		  break;
            case 2:
            	interrupted=1;
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
