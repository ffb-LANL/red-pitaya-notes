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
  int fd, i, data_file;
  volatile uint8_t *rst;
  volatile void *cfg, *sts;
  void *ram;
  uint32_t start, offset, size,pre_samples=8192,tot_samples=1024 * 1024;
  uint32_t value;

  if (argc >=2 ) {
	uint32_t tmp = atoi(argv[1]);
	if (tmp > 0 ) pre_samples=tmp;
  }


  if (argc >=3 ) {
	uint32_t tmp = atoi(argv[2]);
	if (tmp > 0 ) tot_samples=tmp;
  }


  if((data_file = open("/opt/data.dat", O_WRONLY | O_CREAT | O_TRUNC,0666)) < 0)
  {
    perror("open data file");
    return EXIT_FAILURE;
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

  size = 8*8192*sysconf(_SC_PAGESIZE);
  printf("Requesting buffer size %d\n",size);
  if(ioctl(fd, CMA_ALLOC, &size) < 0)
  {
    perror("ioctl");
    return EXIT_FAILURE;
  }
  printf("Writer address %d\n",size);
	
  ram = mmap(NULL, 8*8192*sysconf(_SC_PAGESIZE), PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0);

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

  start = *(uint32_t *)(sts + 4) ;
  printf("Writer position %d\n",start);
  if(write(data_file, &start, sizeof(start))< 0){perror("write"); return EXIT_FAILURE;}
  start = *(uint32_t *)(sts + 0) >> 1;
  printf("Trigger position %d\n",start);
  if(write(data_file, &start, sizeof(start))< 0){perror("write"); return EXIT_FAILURE;}

  start = (start - pre_samples) & 0x03FFFFFF;
  printf("Trigger position minus pre, warped %d. Start+tot %d, max %d\n",start,start+tot_samples,0x03FFFFFF );
  /* print IN1 and IN2 samples */
  if(start+tot_samples <= 0x03FFFFFF )
  {
     if(write(data_file, ram+start*4, tot_samples*4)< 0){perror("write1"); return EXIT_FAILURE;}
  }
  else 
  {
     if(write(data_file, ram+start*4, (0x03FFFFFF-start)*4)< 0){perror("write2"); return EXIT_FAILURE;}
     if(write(data_file, ram, (start + tot_samples - 0x03FFFFFF) *4)< 0){perror("write3"); return EXIT_FAILURE;}
  }
  close(data_file);   

  return EXIT_SUCCESS;
}
