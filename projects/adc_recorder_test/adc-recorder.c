#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <sys/ioctl.h>

#define CMA_ALLOC _IOWR('Z', 0, uint32_t)
#define RAM_START  0x10000000
#define RAM_LENGTH 0x10000000

int main()
{
  int verbose = 1;
  int fd, i;
  volatile uint8_t *rst;
  volatile void *cfg;
  volatile int16_t *ram;
  uint32_t size;
  int16_t value[2];
  char string[100] = {'\0'};

  if((fd = open("/dev/mem", O_RDWR)) < 0)
  {
    perror("open");
    return EXIT_FAILURE;
  }
  if(verbose)perror("mapping cfg sts\n");
  cfg = mmap(NULL, sysconf(_SC_PAGESIZE), PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0x40000000);
  ram = mmap(NULL,RAM_LENGTH , PROT_READ|PROT_WRITE, MAP_SHARED, fd, RAM_START);
  close(fd);
  
  size = 8192*8*sysconf(_SC_PAGESIZE);
  
  if(verbose)perror(" resetting writer\n"); 
  sleep(1);
  rst = (uint8_t *)(cfg + 0);


  if(verbose)perror("init_mem_map: setting writer address\n"); 
  sleep(1);
  // set writer address

  if(verbose)perror("init_mem_map: setting number of samples\n"); 
  sleep(1);
  // set number of samples
  *(uint32_t *)(cfg + 8) = 4096- 1;

  // reset writer
  *rst &= ~4;
  *rst |= 4;

  // reset fifo and filters
  *rst &= ~1;
  *rst |= 1;

  // wait 1 second
  sleep(1);

  // reset packetizer
  *rst &= ~2;
  *rst |= 2;

  // wait 1 second
  sleep(1);

  // print IN1 and IN2 samples
  for(i = 0; i < 1024 ; ++i)
  {
    value[0] = ram[2 * i + 0];
    value[1] = ram[2 * i + 1];
    printf("%5d %5d\n", value[0], value[1]);
  }
  if(verbose)perror("init_mem_map: exiting\n"); 
  return EXIT_SUCCESS;
}
