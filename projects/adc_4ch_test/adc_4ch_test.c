#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <sys/ioctl.h>

int main()
{
  int fd, i;
  int samples=4096;
  volatile uint8_t *rst;
  volatile void *cfg, *sts, *fifo;
  int16_t *buffer;
  int yes = 1;
  uint32_t read_count,write_count;

  if((buffer = (int16_t *)malloc(65536)) == NULL)
  {
    perror("malloc");
    return EXIT_FAILURE;
  }

  if((fd = open("/dev/mem", O_RDWR)) < 0)
  {
    perror("open");
    return EXIT_FAILURE;
  }

  cfg = mmap(NULL, sysconf(_SC_PAGESIZE), PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0x40000000);
  sts = mmap(NULL, sysconf(_SC_PAGESIZE), PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0x41000000);
  fifo = mmap(NULL, 32*sysconf(_SC_PAGESIZE), PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0x42000000);

  close(fd);

  
  rst = (uint8_t *)(cfg + 0);

  read_count =  *(uint32_t *)(sts + 8);
  printf("%x\n ",read_count);
 // reset idly_ctrl
  *rst |= 2;
  usleep(2);
  *rst &= ~2;
  usleep(10);

  read_count =  *(uint32_t *)(sts + 8);
  printf("%x\n ",read_count);

  // reset fifo and filters
  *rst &= ~1;
  read_count = *(uint32_t *)(sts + 0);
  write_count = *(uint32_t *)(sts + 4);

  // printf("%5d %5d ",read_count,write_count);
  // wait 1 second
  sleep(1);

  *rst |= 1;

  // wait 1 second
  sleep(1);
  read_count = *(uint32_t *)(sts + 0);
  write_count = *(uint32_t *)(sts + 4);

  // printf("%5d %5d\n",read_count,write_count);  

  memcpy(buffer, (const void *) fifo, samples*8);
  // print samples
  for(i = 0; i < samples; ++i)
  {
    printf("%5d\t%5d\t%5d\t%5d\t%5d\n",i, buffer[i*4], buffer[i*4+1],buffer[i*4+2], buffer[i*4+3]);
  }

  return EXIT_SUCCESS;
}
