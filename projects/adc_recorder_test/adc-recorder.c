#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <sys/ioctl.h>

#define CMA_ALLOC _IOWR('Z', 0, uint32_t)

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
  if(verbose)perror("test_cma: mapping cfg sts\n");
  cfg = mmap(NULL, sysconf(_SC_PAGESIZE), PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0x40000000);

  close(fd);
  if(verbose)perror("test_cma: oppening CMA\n");
  if((fd = open("/dev/cma", O_RDWR)) < 0)
  {
    perror("open");
    return EXIT_FAILURE;
  }

  size = 8192*8*sysconf(_SC_PAGESIZE);
  sprintf(string, "Allocating CMA ram. Size = %u, pagesize = %u\n", size, sysconf(_SC_PAGESIZE));
  if(verbose)perror(string);  
  if(ioctl(fd, CMA_ALLOC, &size) < 0)
  {
    perror("ioctl");
    return EXIT_FAILURE;
  }
  sprintf(string,"test_cma: mapping ram.Size = %u\n", size );
  if(verbose)perror(string);  

  ram = mmap(NULL, 1024*sysconf(_SC_PAGESIZE), PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0);
  if(verbose)perror("test_cma: resetting writer\n"); 

  rst = (uint8_t *)(cfg + 0);
  if(verbose)perror("init_mem_map: setting writer address\n"); 
  // set writer address
  *(uint32_t *)(cfg + 48) = size;

  // set number of samples
  *(uint32_t *)(cfg + 8) = 1024 * 1024 - 1;

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
  for(i = 0; i < 1024 * 1024; ++i)
  {
    value[0] = ram[2 * i + 0];
    value[1] = ram[2 * i + 1];
    printf("%5d %5d\n", value[0], value[1]);
  }
  if(verbose)perror("init_mem_map: exiting\n"); 
  return EXIT_SUCCESS;
}
