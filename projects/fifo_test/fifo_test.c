#include <stdio.h>
#include <inttypes.h>
#include <stdint.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <sys/ioctl.h>

int main(int argc, char *argv[])
{
  int fd, i;
  int samples=32768;
  volatile uint8_t *rst;
  volatile void *cfg, *sts, *fifo;
  uint64_t *buffer;
  int yes = 1;
  uint32_t read_count,write_count;

  if (argc >=2 ) {
	uint32_t tmp = atoi(argv[2]);
	if (tmp > 0 ) samples=tmp;
  }

  if((buffer = (uint64_t *)malloc(samples*8)) == NULL)
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
  // printf("%x\n ",read_count);


  // reset fifo
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
    printf("%d\t%" PRIu64 "\n",i, buffer[i]);
  }

  return EXIT_SUCCESS;
}
