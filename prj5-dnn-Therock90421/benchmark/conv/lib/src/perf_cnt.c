#include "perf_cnt.h"

volatile unsigned int *perf_cnt = (void *)0x40020000;
volatile unsigned int *mem_cycle = (void *)0x40020008;

unsigned long _uptime() {
  // TODO [COD]
  //   You can use this function to access performance counter related with time or cycle.
  

  return *perf_cnt;
}

unsigned long _read_memory_cycle() {
  
  return *mem_cycle;
}

void bench_prepare(Result *res) {
  // TODO [COD]
  //   Add preprocess code, record performance counters' initial states.
  //   You can communicate between bench_prepare() and bench_done() through
  //   static variables or add additional fields in `struct Result`
  res->msec = _uptime();
  res->mem_cycle = _read_memory_cycle();
}

void bench_done(Result *res) {
  // TODO [COD]
  //  Add postprocess code, record performance counters' current states.
  res->msec = _uptime() - res->msec;
   res->mem_cycle = _read_memory_cycle()-res->mem_cycle;
}

