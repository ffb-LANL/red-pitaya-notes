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
  int samples=16;
  int16_t result;
  volatile uint8_t *rst;
  volatile void *cfg, *sts, *hub;
  uint64_t *buffer;
  double scale = .5;
  uint32_t scaler_cfg,addr,addr1; 
  int offset = -200;
  if (argc >=2 ) {
       // printf("argv2 %s\n",argv[1]);
	scale = atof(argv[1]);
  }
  if (argc >=3 ) {
	offset = atoi(argv[2]);
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
  hub = mmap(NULL, 32768*sysconf(_SC_PAGESIZE), PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0x40000000);
  close(fd);
  scaler_cfg =     (((uint32_t)offset) << 16) | (uint32_t)(scale*32767);
  addr = 2 << 24;
  addr1 = 3 << 24;
	
  *(uint32_t *)(cfg+60)=scaler_cfg;
  printf("Scale %f, offset %d, cfg %u\n",scale, offset,  scaler_cfg);
  for(i = 0; i < samples; ++i)
  {
    // ((int32_t *)(hub+addr1))[i]=
    ((int32_t *)(hub+addr))[i]=i*100+500;
    result = ((int32_t *)(hub+addr))[i];
    if(result & 0x2000) result |=0xe000;
    printf("%d\t%d\n",i,result /* ,((int32_t *)(hub+addr1))[i] */);
  }

  return EXIT_SUCCESS;
}
