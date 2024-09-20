#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <sys/ioctl.h>



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
	


  start = *(uint32_t *)(sts + 0) ;
  printf("Writer position %d\n",start);
  start = 0; 
  if(write(data_file, &start, sizeof(start))< 0){perror("write"); return EXIT_FAILURE;}
  start = *(uint32_t *)(sts + 4) >> 1;
  printf("Trigger position %d\n",start);
  start = (start - pre_samples) & MAX_SAMPLES;
  printf("Trigger position minus pre, warped %d. Start+tot %d, max %d\n",start,start+tot_samples,MAX_SAMPLES );
  start = 0; 
  if(write(data_file, &start, sizeof(start))< 0){perror("write"); return EXIT_FAILURE;}
  tot_samples = MAX_SAMPLES ;

  /* print IN1 and IN2 samples */
   if(write(data_file, ram+start*8, tot_samples*8)< 0){perror("write1"); printf("start*8 %d, tot_samples*8 %d\n", start*8, tot_samples*8); return EXIT_FAILURE;}
   close(data_file);   

  return EXIT_SUCCESS;
}
