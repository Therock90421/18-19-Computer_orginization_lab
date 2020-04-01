#include "printf.h"
#include "trap.h"
#include "perf_cnt.h"


#define HW_ACC_START	0x0000
#define HW_ACC_DONE		0x0008


int main()
{
	//TODO: Please add your own software to control hardware accelerator
	unsigned long *base = (void *)0x40040000;
	unsigned long val;
        volatile unsigned long *val1;
       // volatile unsigned long *val1 = (void *)0x40040008;
        unsigned long val2;
        
	Result res;

        bench_prepare(&res);
        
        printf("starting convolution\n");
	val = *base&0xfffffffe;
	*base = val+1;
	
	while(1)
	{
	    val1 = (void *)0x40040008;
	   // val1 = val1&0x00000001;
            val2 = *val1&0x00000001;

	    //printf("%d\n",val1);
	   // if(val1 > 0)
            if(val2>0)
	    break;
	
	}
	
	bench_done(&res);

        printf("Cycles of sw: %u\n", res.msec);
        printf("Memory visit times is: %u\n",res.mem_cycle);

	return 0;
}
