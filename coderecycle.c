
typedef struct l_time_level {
  struct l_time_level* next;
  l_squeue* cur;
  l_squeue* mid;
  l_int to_unit;
  l_squeue timeq[1];
} l_time_level;

typedef struct {
  l_time_level* next;
  l_squeue* cur_ms;
  l_squeue* mid_ms;
  l_int to_msec;
  l_squeue msecq[1000*2];
} l_time_one_sec;

typedef struct {
  l_time_level* next;
  l_squeue* cur_sec;
  l_squeue* mid_sec;
  l_int to_sec;
  l_squeue secq[60*2];
} l_time_one_min;

typedef struct {
  l_time_level* next;
  l_squeue* cur_min;
  l_squeue* mid_min;
  l_int to_min;
  l_squeue minq[60*2];
} l_time_one_hour;

typedef struct {
  l_time_level* next;
  l_squeue* cur_hour;
  l_squeue* mid_hour;
  l_int to_hour;
  l_squeue hourq[24*2];
} l_time_one_day;

typedef struct {
  l_time_level* next;
  l_squeue* cur_day;
  l_squeue* mid_day;
  l_int to_day;
  l_squeue dayq[356*2];
} l_time_one_year;

typedef struct {
  l_long base_ms;
  l_time_one_sec* sec;
  l_time_one_min* min;
  l_time_one_hour* hour;
  l_time_one_day* day;
  l_time_one_year* year;
  l_time_one_sec s;
  l_time_one_min m;
  l_time_one_hour h;
  l_time_one_day d;
  l_time_one_year y;
} l_time_chain;

static void
l_time_chain_init(l_time_chain* tchn, l_long cur_ms)
{
  l_zero_n(tchn, sizeof(l_time_chain));

  tchn->base_ms = cur_ms;
  tchn->sec = &tchn->s;
  tchn->min = &tchn->m;
  tchn->hour = &tchn->h;
  tchn->day = &tchn->d;
  tchn->year = &tchn->y;

  tchn->sec->next = (l_time_level*)tchn->min;
  tchn->sec->cur_ms = tchn->sec->msecq;
  tchn->sec->mid_ms = tchn->sec->msecq + 1000;
  tchn->sec->to_msec = 1;

  tchn->min->next = (l_time_level*)tchn->hour;
  tchn->min->cur_sec = tchn->min->secq;
  tchn->min->mid_sec = tchn->min->secq + 60;
  tchn->min->to_sec = 1000;

  tchn->hour->next = (l_time_level*)tchn->day;
  tchn->hour->cur_min = tchn->hour->minq;
  tchn->hour->mid_min = tchn->hour->minq + 60;
  tchn->hour->to_min = 1000 * 60;

  tchn->day->next = (l_time_level*)tchn->year;
  tchn->day->cur_hour = tchn->day->hourq;
  tchn->day->mid_hour = tchn->day->hourq + 24;
  tchn->day->to_hour = 1000 * 60 * 60;
  
  tchn->year->next = 0; 
  tchn->year->cur_day = tchn->year->dayq;
  tchn->year->mid_day = tchn->year->dayq + 356;
  tchn->year->to_day = 1000 * 60 * 60 * 24;
}

static l_bool
l_master_add_timer(l_master* M, l_timer_node* timer)
{
  l_time_chain* tchn = &M->ttbl->time_chain;
  l_long diff = timer->expire_time - M->stamp->mast_time_ms;

  if (diff <= 1000) { /* diff are msecs */
    if (diff < 1) diff = 1;
    l_squeue_push(tchn->sec->cur_ms + diff - 1, &timer->node);
    return true;
  }

  diff = diff / 1000; /* diff are secs now */
  if (diff <= 60) {
    l_squeue_push(tchn->min->cur_sec + diff - 1, &timer->node);
    return true;
  }

  diff = diff / 60; /* diff are mins now */
  if (diff <= 60) {
    l_squeue_push(tchn->hour->cur_min + diff - 1, &timer->node);
    return true;
  }

  diff = diff / 60; /* diff are hours now */
  if (diff <= 24) {
    l_squeue_push(tchn->day->cur_hour + diff - 1, &timer->node);
    return true;
  }

  diff = diff / 24; /* diff are days now */
  if (diff <= 356) {
    l_squeue_push(tchn->year->cur_day + diff - 1, &timer->node);
    return true;
  }

  l_timertable_free_node(M->ttbl, timer);

  l_loge_1(M->E, "timer fire time (%d days) too long", ld(diff));
  return false;
}

static l_int
l_master_move_timers_up(l_master* M, l_time_level* cur_level, l_squeue timers)
{
  l_time_chain* tchn = &M->ttbl->time_chain;
  l_int qcnt = cur_level->mid - cur_level->timeq;
  l_timer_node* timer = 0;
  l_long diff_time = 0; 
  l_int move_back_count = 0;

  while ((timer = (l_timer_node*)l_squeue_pop(&timers))) {
    diff_time = (timer->expire_time - tchn->base_ms) / cur_level->to_unit;
    if (diff_time <= 1) diff_time = 1;
    if (diff_time <= qcnt) {
      l_squeue_push(cur_level->cur + diff_time - 1, &timer->node);
    } else {
      move_back_count += 1;
      l_squeue_push(cur_level->next->cur, &timer->node);
    }
  }

  return move_back_count;
}

static void
l_master_check_timers(l_master* M)
{
  /** Timer Scheduling Example **

  pre-assumptions
  - the time begins at 0-msec
  - 1st level timer resolution is 1-msec
  - 2nd level timer resolution is 4-msec, so the 1st level only has 4*2 slots
  - tm1(T=1ms), tm3(T=3ms), tm4(T=4ms), tm5(T=5ms) are inserted at time 0-msec

  1. initial
  base_ms 0-msec
  [1st level] array idx -   0     1     2     3  |  4     5     6     7     8
  fire time from 0-msec   [1ms] [2ms] [3ms] [4ms]|[5ms] [6ms] [7ms] [8ms]
         current timers   [tm1] [   ] [tm3] [tm4]|[   ] [   ] [   ] [   ]
                      cur_1 ^                    |
  ---
                          [2nd level] array idx -            0                       1                      2
                          fire time from 0-msec   [         4ms         ] [         8ms         ]
                                 current timers   [         tm5         ] [                     ]
                                              cur_2 ^

  2. after 2ms (tm1 is fired, update base time to current time)
  base_ms 2-msec
  [1st level] array idx -   0     1     2     3  |  4     5     6     7     8
  fire time from 0-msec   [1ms] [2ms] [3ms] [4ms]|[5ms] [6ms] [7ms] [8ms]
         current timers   [   ] [   ] [tm3] [tm4]|[   ] [   ] [   ] [   ]
                                 cur_1 ^         |
  ---
                          [2nd level] array idx -            0                       1                      2
                          fire time from 0-msec   [         4ms         ] [         8ms         ]
                                 current timers   [         tm5         ] [                     ]
                                              cur_2 ^

  3. add timer tm6(T=4ms), tm7(T=5ms)
  ---
  tm6 : current time + T - base time = T = 4 <= 4, insert into level 1
  tm7 : current time + T - base time = T = 5 > 4, insert into level 2
  ---
  base_ms 2-msec
  [1st level] array idx -   0     1     2     3  |  4     5     6     7     8
  fire time from 0-msec   [1ms] [2ms] [3ms] [4ms]|[5ms] [6ms] [7ms] [8ms]
         current timers   [   ] [   ] [tm3] [tm4]|[   ] [tm6] [   ] [   ]
                                 cur_1 ^         |
  ---
                          [2nd level] array idx -            0                       1                      2
                          fire time from 0-msec   [         4ms         ] [         8ms         ]
                                 current timers   [      tm5, tm7       ] [                     ]
                                              cur_2 ^

  4. 3ms later (tm3, tm4, tm5 should be fired)
  base_ms 2-msec
  [1st level] array idx -   0     1     2     3  |  4     5     6     7     8
  fire time from 0-msec   [1ms] [2ms] [3ms] [4ms]|[5ms] [6ms] [7ms] [8ms]
         current timers   [   ] [   ] [tm3] [tm4]|[   ] [tm6] [   ] [   ]
                                 cur_1 ^          |  fire ^
  ---
                          [2nd level] array idx -            0                       1                      2
                          fire time from 0-msec   [       5ms-8ms       ] [       9ms-16ms      ]
                                 current timers   [      tm5, tm7       ] [                     ]
                                              cur_2 ^
  ---
  a. fire tm3 and tm4 are easy, because they are just before fire position, how to fire tm5 ?
  b. current difference is the fire position crossed the middle line, fire time now is overlapped with the 1st slot in level 2
  c. we should re-insert all timers in the level 2 first slot, below is the state after re-insert
  ---
base_ms 2-msec
  [1st level] array idx -   0     1     2     3  |  4     5     6     7     8
  fire time from 0-msec   [1ms] [2ms] [3ms] [4ms]|[5ms] [6ms] [7ms] [8ms]
         current timers   [   ] [   ] [tm3] [tm4]|[tm5] [tm6] [   ] [   ]
                                 cur_1 ^          |  fire ^
  ---
                          [2nd level] array idx -            0                       1                      2
                          fire time from 0-msec   [       5ms-8ms       ] [       9ms-16ms      ]
                                 current timers   [         tm7         ] [                     ]
                                              cur_2 ^
  ---
  d. now fire tm3, tm4, and tm5, and update base time to current
  ---
  base_ms 5-msec
  [1st level] array idx -   0     1     2     3  |  4     5     6     7     8
  fire time from 0-msec   [1ms] [2ms] [3ms] [4ms]|[5ms] [6ms] [7ms] [8ms]
         current timers   [   ] [   ] [   ] [   ]|[   ] [tm6] [   ] [   ]
                                                 | cur_1 ^
  ---
                          [2nd level] array idx -            0                       1                      2
                          fire time from 0-msec   [       5ms-8ms       ] [       9ms-16ms      ]
                                 current timers   [         tm7         ] [                     ]
                                              cur_2 ^
  ---
  e. but there are less than 4-slot after cur_1, we shall ajust cur_1 back to the slot before middle line
  f. even more, current time is passed more than 4ms (level 2 resolution), we should also move cur_2 one step forward, just like level 1 did
  g. and the timers left in the original cur_2 position should all re-insert
  ---
  base_ms 5-msec
  [1st level] array idx -   0     1     2     3  |  4     5     6     7     8
  fire time from 0-msec   [1ms] [2ms] [3ms] [4ms]|[5ms] [6ms] [7ms] [8ms]
         current timers   [   ] [tm6] [tm7] [   ]|[   ] [   ] [   ] [   ]
                            cur_1 ^              |
  ---
                          [2nd level] array idx -            0                       1                      2
                          fire time from 0-msec   [       5ms-8ms       ] [       9ms-16ms      ]
                                 current timers   [                     ] [                     ]
                                                                      cur_2 ^
  ---
  h. what if after move cur_2, it also crossed its middle line ?
  i. we should also move cur_2 back to the slot before middle line, and should re-insert cur_3 and move cur_3 one step forward **/

  l_time_chain* tchn = &M->ttbl->time_chain;
  l_long current_time = M->stamp->mast_time_ms;
  l_long time_lapse = current_time - tchn->base_ms;
  l_timer_node* timer = 0;
  l_time_level* cur_level = (l_time_level*)tchn->sec;
  l_time_level* next_level = 0;
  l_squeue* fired = 0;
  l_squeue* temp = 0;
  l_squeue fired_q;
  l_int qcnt = 0;

  l_squeue_init(&fired_q);

  if (time_lapse <= 0) {
    return;
  }
continue_next_level:

  if (cur_level == 0) {
    l_loge_s(M->E, "this timer check is too long after previous");
    return;
  }

  qcnt = cur_level->mid - cur_level->timeq;
  next_level = cur_level->next;

  if (time_lapse < qcnt) {
    fired = cur_level->cur + time_lapse;

    if (fired >= cur_level->mid && next_level) {
      l_master_move_timers_up(M, cur_level, l_squeue_move(next_level->cur));
    }

    for (temp = cur_level->cur; temp < fired; temp += 1) {
      l_squeue_push_queue(&fired_q, temp);
    }

    tchn->base_ms = current_time;

    if (fired >= cur_level->mid) {
      l_copy_n(cur_level->timeq, cur_level->mid, sizeof(l_squeue) * qcnt);
      l_zero_n(cur_level->mid, sizeof(l_squeue) * qcnt);
      cur_level->cur = cur_level->timeq + (fired - cur_level->mid);

      while (next_level) {
        next_level->cur += 1;
        l_master_move_timers_up(M, cur_level, l_squeue_move(next_level->cur - 1));

        if (next_level->cur >= next_level->mid) {
          qcnt = next_level->mid - next_level->timeq;
          l_copy_n(next_level->timeq, next_level->mid, sizeof(l_squeue) * qcnt);
          l_zero_n(next_level->mid, sizeof(l_squeue) * qcnt);
          next_level->cur = next_level->timeq;

          cur_level = next_level;
          next_level = cur_level->next;
        }
      }
    } else {
      cur_level->cur = fired;
    }

    while ((timer = (l_timer_node*)l_squeue_pop(&fired_q))) {
      l_master_fire_timer(M, timer);
    }

    return;
  }
  /* all cur_level timers are fired */

  l_assert(M->E, cur_level->cur < cur_level->mid);

  for (temp = cur_level->cur; temp < cur_level->cur + qcnt; temp += 1) {
    l_squeue_push_queue(&fired_q, temp);
  }

  cur_level->cur = cur_level->timeq + time_lapse % qcnt;
  time_lapse /= qcnt;

  cur_level = next_level;
  goto continue_next_level;
}

static void*
lua_alloc_func(void* ud, void* p, size_t oldsz, size_t newsz)
{
  if (newsz == 0) {
    printf("free %d\n", (int)oldsz);
    l_rawapi_mfree(ud, p);
    return 0;
  } else if (p == 0) {
    printf("alloc %d\n", (int)newsz);
    return l_rawapi_malloc(ud, newsz);
  } else {
    printf("free %d and alloc %d\n", (int)oldsz, (int)newsz);
    return realloc(p, newsz);
  }
}

#define l_mallocEx(allocfunc, ud, size) allocfunc((ud), 0, 0, (size))
#define l_callocEx(allocfunc, ud, size) allocfunc((ud), 0, 1, (size))
#define l_rallocEx(allocfunc, ud, buffer, oldsize, newsize) allocfunc((ud), (buffer), (oldsize), (newsize))
#define l_mfreeEx(allocfunc, ud, buffer) allocfunc((ud), (buffer), 0, 0)

#define l_malloc(allocfunc, size) l_mallocEx(allocfunc, 0, (size))
#define l_calloc(allocfunc, size) l_callocEx(allocfunc, 0, (size))
#define l_ralloc(allocfunc, buffer, oldsize, newsize) l_rallocEx(allocfunc, 0, (buffer), (oldsize), (newsize))
#define l_mfree(allocfunc, buffer) l_mfreeEx(allocfunc, 0, (buffer))

#define l_raw_malloc(size) l_malloc(l_raw_alloc_func, size)
#define l_raw_calloc(size) l_calloc(l_raw_alloc_func, size)
#define l_raw_ralloc(buffer, oldsize, newsize) l_ralloc(l_raw_alloc_func, buffer, oldsize, newsize)
#define l_raw_mfree(buffer) l_mfree(l_raw_alloc_func, buffer)

typedef void* (*l_allocfunc)(void* userdata, void* buffer, l_int oldsize, l_int newsize);
L_EXTERN void* l_raw_alloc_func(void* userdata, void* buffer, l_int oldsize, l_int newsize);

static void*
l_out_of_memory(l_int size, int init)
{
  l_process_exit();
  (void)size;
  (void)init;
  return 0;
}

static l_int
l_check_alloc_size(l_int size)
{
  if (size > L_MAX_RWSIZE) return 0;
  if (size <= 0) return 8;
  return (((size - 1) >> 3) + 1) << 3; /* times of eight */
}

static void*
l_raw_alloc_f(void* p) {
  if (p) free(p);
  return 0;
}

static void*
l_raw_alloc_m(l_int size)
{
  void* p = 0;
  l_int n = l_check_alloc_size(size);
  if (!n) {
    l_loge_1("large %d", ld(size));
  } else {
    if (!(p = malloc(l_cast(size_t, n)))) {
      p = l_out_of_memory(n, 0);
    }
  }
  return p; /* the memory is not initialized */
}

static void*
l_raw_alloc_c(l_int size) {
  void* p = 0;
  l_int n = l_check_alloc_size(size);
  if (!n) { l_loge_1("large %d", ld(size)); return 0; }
  /* void* calloc(size_t num, size_t size); */
  p = calloc(l_cast(size_t, n) >> 3, 8);
  if (p) return p;
  return l_out_of_memory(n, 1);
}

static void* /* if alloc failed, need keep p unchanged */
l_raw_alloc_r(void* p, l_int old, l_int newsz) {
  void* temp = 0;
  l_int n = l_check_alloc_size(newsz);
  if (!p || old <= 0 || n == 0) { l_loge_1("size %d", ld(newsz)); return 0; }

  /** void* realloc(void* buffer, size_t size); **
  Changes the size of the memory block pointed by buffer. The function
  may move the memory block to a new location (its address is returned
  by the function). The content of the memory block is preserved up to
  the lesser of the new and old sizes, even if the block is moved to a
  new location. ***If the new size is larger, the value of the newly
  allocated portion is indeterminate***.
  In case of that buffer is a null pointer, the function behaves like malloc,
  assigning a new block of size bytes and returning a pointer to its beginning.
  If size is zero, the memory previously allocated at buffer is deallocated
  as if a call to free was made, and a null pointer is returned. For c99/c11,
  the return value depends on the particular library implementation, it may
  either be a null pointer or some other location that shall not be dereference.
  If the function fails to allocate the requested block of memory, a null
  pointer is returned, and the memory block pointed to by buffer is not
  deallocated (it is still valid, and with its contents unchanged). */

  if (n > old) {
    temp = realloc(p, l_cast(size_t, n));
    if (temp) { /* the newly allocated portion is indeterminate */
      l_zero_n(temp + old, n - old);
      return temp;
    }
    if ((temp = l_out_of_memory(n, 0))) {
      l_copy_n(p, old, temp);
      l_zero_n(temp + old, n - old);
      l_raw_alloc_f(p);
      return temp;
    }
  } else {
    temp = realloc(p, l_cast(size_t, n));
    if (temp) return temp;
    if ((temp = l_out_of_memory(n, 0))) {
      l_copy_n(p, n, temp);
      l_raw_alloc_f(p);
      return temp;
    }
  }
  return 0;
}

L_EXTERN void*
l_raw_alloc_func(void* userdata, void* buffer, l_int oldsize, l_int newsize)
{
  (void)userdata;
  if (!buffer) {
    if (oldsize) return l_raw_alloc_c(newsize);
    return l_raw_alloc_m(newsize);
  }
  if (newsize) return l_raw_alloc_r(buffer, oldsize, newsize);
  return l_raw_alloc_f(buffer);
}
