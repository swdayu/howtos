
# POSIX Thread

## Thread

```c
int pthread_create(pthread_t* thread, const pthread_attr_t* attr, void* (*start_routine)(void*), void* arg);
int pthread_join(pthread_t thread, void** retval);
```

The **pthread_create** function starts a new thread n the calling process.
The new thread starts execution by invoking `start_routine`, `arg` is passed as the sole argument.

On success, **pthread_create** returns 0; on error, it returns an error number, 
and the contents of `*thread` are undefined.

---------------------------------------------------------------------------------------

The **pthread_join** function waits for the thread specified by `thread` to terminate.
If that thread has already terminated, then **pthread_join** returns immediately.
The thread specified by `thread` must be joinable.

If `retval` is not `NULL`, then **pthread_join** copies the exit status of the target thread into `*retval`.
If the target thread was canceled, then `PTHREAD_CANCELED` is placed in `*retval`.

If multiple threads simultaneously try to join with the same thread, the results are undefined.
If the thread calling **pthread_join** is canceled, then the target thread will remain joinable 
(i.e. it will not be detached).

On success, **pthread_join** returns 0; on error, it returns an error number.
Note that after a successful call to **pthread_join**, 
the caller is guaranteed that the target thread has terminated.
Joining with a thread that has previously been joined results in undefined behavior.


## Mutex

```c
pthread_mutex_t mutext = PTHREAD_MUTEX_INITIALIZER;
int pthread_mutex_init(pthread_mutex_t* mutex, const pthread_mutexaddr_t* attr);
int pthread_mutex_destory(pthread_mutex_t* mutex);
```

## Condition Variable

```c
pthread_cond_t cond = PTHREAD_COND_INITIALIZER;
int pthread_cond_init(pthread_cond_t* cond, const pthread_condattr_t* attr);
int pthread_cond_destroy(pthread_cond_t* cond);
```

