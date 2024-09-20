#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <sys/ioctl.h>

#define CMA_ALLOC _IOWR('Z', 0, uint32_t)
#define CMA_SIZE 8*8192*sysconf(_SC_PAGESIZE)


int main(int argc, char *argv[])
{
  int fd, i, data_file;
  volatile uint8_t *rst;
  volatile void *cfg, *sts;
  void *ram;
  uint32_t start, offset, size,pre_samples=8192,tot_samples=1024 * 1024;
  uint32_t value;

  size = CMA_SIZE;

  if (argc >=2 ) {
	uint32_t tmp = atoi(argv[1]);
	if (tmp > 0 ) size=tmp;
  }


  if (argc >=3 ) {
	uint32_t tmp = atoi(argv[2]);
	if (tmp > 0 ) tot_samples=tmp;
  }


  if(write(data_file, &pre_samples, sizeof(pre_samples))< 0){perror("write"); return EXIT_FAILURE;}
  if(write(data_file, &tot_samples, sizeof(tot_samples))< 0){perror("write"); return EXIT_FAILURE;}

  if((fd = open("/dev/mem", O_RDWR)) < 0)
  {
    perror("open");
    return EXIT_FAILURE;
  }

  cfg = mmap(NULL, sysconf(_SC_PAGESIZE), PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0x40000000);
  sts = mmap(NULL, sysconf(_SC_PAGESIZE), PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0x41000000);

  close(fd);

  if((fd = open("/dev/cma", O_RDWR)) < 0)
  {
    perror("open");
    return EXIT_FAILURE;
  }

  printf("Requesting buffer size %d\n",size);
  if(ioctl(fd, CMA_ALLOC, &size) < 0)
  {
    perror("ioctl");
    return EXIT_FAILURE;
  }
  printf("Writer address %d\n",size);

  return EXIT_SUCCESS;
}
