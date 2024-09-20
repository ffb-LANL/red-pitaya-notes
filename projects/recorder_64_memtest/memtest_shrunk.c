#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <sys/ioctl.h>

#define CMA_ALLOC _IOWR('Z', 0, uint32_t)
#define CMA_SIZE 8*8192*sysconf(_SC_PAGESIZE)
#define RAM_START  0x10000000
#define RAM_LENGTH 0x10000000
#define MAX_SAMPLES 0x1FFFFFF

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
  ram = mmap(NULL,RAM_LENGTH , PROT_READ|PROT_WRITE, MAP_SHARED, fd, RAM_START);

  close(fd);
  

  size = RAM_START;
  printf("Writer address %d\n",size);
	
  rst = (uint8_t *)(cfg + 0);

  /* reset oscilloscope and ram writer */
  *rst &= ~1;
  *rst |= 1;

  /* set number of samples before trigger */
  *(uint32_t *)(cfg + 52) = pre_samples- 1;

  /* set total number of samples (up to 8 * 1024 * 1024 - 1) */
  *(uint32_t *)(cfg + 4) = tot_samples - 1;

  /* start oscilloscope */
  *rst |= 2;
  *rst &= ~2;

  /* wait when oscilloscope stops */
  while(*(uint32_t *)(sts + 4) & 1)
  {
    usleep(1000);
  }

  start = *(uint32_t *)(sts + 0) ;
  printf("Writer position %d\n",start);
  if(write(data_file, &start, sizeof(start))< 0){perror("write"); return EXIT_FAILURE;}
  start = *(uint32_t *)(sts + 4) >> 1;
  printf("Trigger position %d\n",start);
  if(write(data_file, &start, sizeof(start))< 0){perror("write"); return EXIT_FAILURE;}

  start = (start - pre_samples) & MAX_SAMPLES;
  printf("Trigger position minus pre, warped %d. Start+tot %d, max %d\n",start,start+tot_samples,MAX_SAMPLES );
  /* print IN1 and IN2 samples */
  if(start+tot_samples <= MAX_SAMPLES )
  {
     if(write(data_file, ram+start*8, tot_samples*8)< 0){perror("write1"); printf("start*8 %d, tot_samples*8 %d\n", start*8, tot_samples*8); return EXIT_FAILURE;}
  }
  else 
  {
     if(write(data_file, ram+start*8, (MAX_SAMPLES+1-start)*8)< 0){perror("write2"); return EXIT_FAILURE;}
     if(write(data_file, ram, (start + tot_samples - MAX_SAMPLES ) *8)< 0){perror("write3"); return EXIT_FAILURE;}
  }
  close(data_file);   

  return EXIT_SUCCESS;
}
