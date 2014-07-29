/*
 * Copyright (c) 2013, Dennis <dennis.cpp@gmail.com>.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are
 * met:
 *
 * 1. Redistributions of source code must retain the above copyright
 * notice, this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright
 * notice, this list of conditions and the following disclaimer in the
 * documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

/**
 * @file thread_pool.h
 * @brief Threadpool header file
 */

#ifndef _THREAD_POOL_H_
#define _THREAD_POOL_H_

#include "platform_def.h"

#if defined WIN32

#define thr_THREAD HANDLE
#define thr_THREAD_RET unsigned
#define thr_THREAD_CALL __stdcall

#define thr_MUTEX HANDLE
#define thr_SEM HANDLE

#elif defined LINUX

#define thr_THREAD pthread_t
#define thr_THREAD_RET void*
#define thr_THREAD_CALL

#define thr_MUTEX pthread_mutex_t

typedef struct
{
	pthread_mutex_t mutex;
	pthread_cond_t cond;
	int count;
} thr_thread_sem_t;
#define thr_SEM thr_thread_sem_t

#elif defined VXWORKS

#define thr_THREAD pthread_t
#define thr_THREAD_RET void*
#define thr_THREAD_CALL

#define thr_MUTEX pthread_mutex_t

typedef struct
{
	pthread_mutex_t mutex;
	pthread_cond_t cond;
	int count;
} thr_thread_sem_t;
#define thr_SEM thr_thread_sem_t

#endif

typedef thr_THREAD_RET (thr_THREAD_CALL *thr_THREAD_FUNC)(void *arg);


typedef enum {
    threadpool_invalid = -1,
    threadpool_lock_failure = -2,
    threadpool_queue_full = -3,
    threadpool_shutdown = -4,
    threadpool_thread_failure = -5
} threadpool_error_t;

typedef struct {
	thr_THREAD *pthrds;
	UINT32 count;
} thrdtab_t;

typedef enum { IDLE, WAITING, PROCESSING } taskstate_t;

typedef struct {
    void (*thrdfunc)(void *);
    void *arg;
} thrdcall_t;

typedef struct {
	UINT32 taskid;
	taskstate_t state;    /* the current state of task */
	thrdcall_t thrdcall;  /* task process function, defined by user */
	thrdcall_t thrdexit;  /* function executed when task finish */
	UINT32 pri;           /* priority */
} task_t;

typedef struct {
	task_t *ptasks;
	UINT32 count;         /* the max count of tasks permited */
	UINT32 waitcount;     /* the count of task in WAITING state */
	UINT32 proscount;     /* the count of task in PROCESSING state */
	UINT32 prino;         /* increasing number, set the coming task's priority */
} tasktab_t;

typedef struct {
	thrdtab_t thrdtab;
	tasktab_t tasktab;
	thr_MUTEX thrdmutex;
	thr_SEM thread_sem;
	UINT8 logfile[256];   /* log file name */
} thrdpool_t;


#ifdef __cplusplus
extern "C" {
#endif

	/**
	 * @function thr_createThrdPool
	 * @brief create a thread pool
	 * @param maxthrds max threads count permit to create
	 * @param maxtasks max tasks count permit to create
	 * @param plogfile log file name
	 * @return a newly created thread pool or NULL
	 */
	thrdpool_t * thr_createThrdPool(int maxthrds, int maxtasks, char *plogfile);

	/**
	 * @function thr_destroyThrdPool
	 * @brief destroy threadpool
	 * @param pthrdpool Thread pool to which add the task.
	 * @return 0 if all goes well, negative values in case of error (@see
	 * threadpool_error_t for codes).
	 */
	int thr_destroyThrdPool(thrdpool_t *pthrdpool);

	/**
	 * @function thr_add_task
	 * @brief add a new task in the queue of a thread pool
	 * @param pthrdpool Thread pool to which add the task.
	 * @param taskid the identifier used by user to identify the task, 
	 * @param thrdcall task structure that will perform the task instance.
	 * @param thrdexit task structure that will perform the task exit.
	 * @return 0 if all goes well, negative values in case of error (@see
	 * threadpool_error_t for codes).
	 */
	int thr_add_task(thrdpool_t *pthrdpool, unsigned int taskid, 
                     thrdcall_t thrdcall, thrdcall_t thrdexit);

#ifdef __cplusplus
}
#endif

#endif
