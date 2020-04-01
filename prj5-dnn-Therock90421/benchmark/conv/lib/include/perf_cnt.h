
#ifndef __PERF_CNT__
#define __PERF_CNT__

#ifdef __cplusplus
extern "C" {
#endif

typedef struct Result {
  unsigned long msec;
  unsigned long mem_cycle;
} Result;

//unsigned long _uptime();
void bench_prepare(Result *res);
void bench_done(Result *res);

#endif
