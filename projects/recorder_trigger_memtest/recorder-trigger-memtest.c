#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <sys/ioctl.h>

#define CMA_ALLOC _IOWR('Z', 0, uint32_t)

int main(int argc, char *argv[])
{
  int fd, i;
  volatile uint8_t *rst;
  volatile void *cfg, *sts, *ram;
  uint32_t start, offset, size,pre_samples=8192,tot_samples=1024 * 1024;
  int32_t value;

  if (argc >=2 ) {
	uint32_t tmp = atoi(argv[1]);
	if (tmp > 0 ) pre_samples=tmp;
  }


  if (argc >=3 ) {
	uint32_t tmp = atoi(argv[2]);
	if (tmp > 0 ) tot_samples=tmp;
  }

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

  size = 8192*sysconf(_SC_PAGESIZE);

  if(ioctl(fd, CMA_ALLOC, &size) < 0)
  {
    perror("ioctl");
    return EXIT_FAILURE;
  }

  ram = mmap(NULL, 8192*sysconf(_SC_PAGESIZE), PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0);

  rst = (uint8_t *)(cfg + 0);

  /* set writer address */
  *(uint32_t *)(cfg + 4) = size;

  /* reset oscilloscope and ram writer */
  *rst &= ~1;
  *rst |= 1;

  /* configure trigger edge (0 for negative, 1 for positive) */
  *(uint16_t *)(cfg + 2) = 0;

  /* set trigger mask */
  *(uint16_t *)(cfg + 8) = 1;

  /* set trigger level */
  *(uint16_t *)(cfg + 10) = 1;

  /* set number of samples before trigger */
  *(uint32_t *)(cfg + 12) = pre_samples- 1;

  /* set total number of samples (up to 8 * 1024 * 1024 - 1) */
  *(uint32_t *)(cfg + 16) = tot_samples - 1;

  /* set decimation factor for CIC filter (from 5 to 3125) */
  /* combined (CIC and FIR) decimation factor is twice greater */
  *(uint16_t *)(cfg + 20) = 5;

  /* start oscilloscope */
  *rst |= 2;
  *rst &= ~2;

  /* wait when oscilloscope stops */
  while(*(uint32_t *)(sts + 0) & 1)
  {
    usleep(1000);
  }

  start = *(uint32_t *)(sts + 0) >> 1;
  start = (start - pre_samples) & 0x007FFFC0;

  /* print IN1 and IN2 samples */
  for(i = 0; i < tot_samples; ++i)
  {
    offset = ((start + i) & 0x007FFFFF) * 4;
    value = *(int16_t *)(ram + offset);
    printf("%10d\n", value);
  }

  return EXIT_SUCCESS;
}
