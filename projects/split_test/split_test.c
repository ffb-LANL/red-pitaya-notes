#include <stdio.h>
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
  int samples=1024;
  volatile void *cfg, *sts, *fifo_x_in, *fifo_x_out,*fifo_y_out ;
  uint32_t count_x,count_y,data;

  if (argc >=2 ) {
	uint32_t tmp = atoi(argv[1]);
	if (tmp > 0 ) samples=tmp;
  }


  if((fd = open("/dev/mem", O_RDWR)) < 0)
  {
    perror("open");
    return EXIT_FAILURE;
  }

  cfg = mmap(NULL, sysconf(_SC_PAGESIZE), PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0x40000000);
  sts = mmap(NULL, sysconf(_SC_PAGESIZE), PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0x41000000);
  fifo_x_in = mmap(NULL, 32*sysconf(_SC_PAGESIZE), PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0x42000000);
  fifo_x_out = mmap(NULL, 32*sysconf(_SC_PAGESIZE), PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0x43000000);
  fifo_y_out = mmap(NULL, 32*sysconf(_SC_PAGESIZE), PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0x44000000);
  close(fd);

  for(i = 0; i <   samples; ++i)
  {
    *(uint32_t *)fifo_x_in = (uint32_t)i;
//    printf("%d\n",i);
   }
  sleep(1);

  count_x =  *(uint32_t *)(sts + 24);
  count_y = *(uint32_t *)(sts + 32);

  printf("x data\n");
  for(i = 0; i <   count_x; ++i)
  {
    data =  *(uint32_t *)fifo_x_out;
    printf("%d %d\n",i, data);
  }
  printf("y data\n");
  for(i = 0; i <   count_y; ++i)
  {
    data =  *(uint32_t *)fifo_y_out;
    printf("%d %d\n",i, data);
  }
  printf("Counts: %d %d\n ",count_x,count_y);
  return EXIT_SUCCESS;
}
