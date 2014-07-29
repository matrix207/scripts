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
 * @file thread_pool.c
 * @brief Threadpool implementation file
 */

#include "thread_pool.h"

#define thr_THREAD_RET_SETPRI           -1

#define thr_MUTEX_RET_CREATEFAILED      -1
#define thr_MUTEX_RET_NOTOWNER          -2
#define thr_MUTEX_RET_LOCKERROR         -3
#define thr_MUTEX_RET_UNLOCKERROR       -4

#define thr_SEM_RET_CREATEFAILED        -1
#define thr_SEM_RET_POSTERROR           -2
#define thr_SEM_RET_WAITERROR           -3
#define thr_SEM_RET_TIMEOUT             -4

BOOL thr_thread_create(thr_THREAD* handle, thr_THREAD_FUNC func, void *arg)
{
#if defined WIN32
	*handle = (thr_THREAD)_beginthreadex(NULL, 0, func, arg, 0, NULL);
	if (0 == *handle)
		return FALSE;

#elif defined LINUX
	if (handle == NULL)
		return FALSE;
	memset(handle, 0, sizeof(thr_THREAD));

	if (pthread_create(handle, NULL, func, arg))
		return FALSE;

#elif defined VXWORKS

#define thr_THREAD_PRIORITY_INVXWORKS 10

	pthread_attr_t attr;
	struct sched_param schedparam;

	if (handle == NULL)
		return FALSE;

	memset(handle, 0, sizeof(thr_THREAD));
	memset(&attr, 0, sizeof(attr));
	memset(&schedparam, 0, sizeof(schedparam));

	if (pthread_attr_init(&attr))
		return FALSE;

	if (pthread_attr_setstacksize(&attr, 512 * 1024))
		return FALSE;

	if (pthread_attr_setinheritsched(&attr, PTHREAD_EXPLICIT_SCHED))
		return FALSE;

	if (pthread_attr_setschedpolicy(&attr, SCHED_FIFO))
		return FALSE;

	schedparam.sched_priority = thr_THREAD_PRIORITY_INVXWORKS;
	if (pthread_attr_setschedparam(&attr, &schedparam))
		return FALSE;

	if (pthread_create(handle, &attr, func, arg))
		return FALSE;

#endif

	return TRUE;
};

void thr_thread_join(thr_THREAD handle)
{
#if defined WIN32
	WaitForSingleObject(handle, INFINITE);
	CloseHandle(handle);

#elif defined LINUX
	pthread_join(handle, NULL);

#elif defined VXWORKS
	pthread_join(handle, NULL);
#endif
}

void thr_thread_exit()
{
#if defined WIN32
	_endthreadex(0);

#elif defined LINUX
	pthread_exit(NULL);

#elif defined VXWORKS
	pthread_exit(NULL);

#endif
}

int thr_thread_set_priority(thr_THREAD handle, int priority)
{
#if defined WIN32
	return -1;

#elif defined LINUX
	return -1;

#elif defined VXWORKS
	int policy = 0;
	struct sched_param schedparam;

	memset(&schedparam, 0, sizeof(schedparam));
	if (pthread_getschedparam(handle, &policy, &schedparam))
		return thr_THREAD_RET_SETPRI;

	memset(&schedparam, 0, sizeof(schedparam));
	schedparam.sched_priority = priority;
	if (pthread_setschedparam(handle, policy, &schedparam))
		return thr_THREAD_RET_SETPRI;

#endif

	return 0;
}

int thr_thread_reschedule()
{
#if defined WIN32

#elif defined LINUX

#elif defined VXWORKS
	if (ERROR == taskDelay(0))
		ERROR_PRINT("taskDelay return error!");
#endif

	return 0;
}

int thr_mutex_init(thr_MUTEX* handle)
{
#if defined WIN32
	*handle = CreateMutex(0, FALSE, 0);
	if (NULL == *handle)
		return thr_MUTEX_RET_CREATEFAILED;

#elif defined LINUX
	if (pthread_mutex_init(handle, NULL))
		return thr_MUTEX_RET_CREATEFAILED;

#elif defined VXWORKS
	if (handle == NULL)
		return thr_MUTEX_RET_CREATEFAILED;
	memset(handle, 0, sizeof(thr_MUTEX));

	if (pthread_mutex_init(handle, NULL))
		return thr_MUTEX_RET_CREATEFAILED;

#endif

	return 0;
}

int thr_mutex_destroy(thr_MUTEX* handle)
{
#if defined WIN32
	if (WaitForSingleObject(*handle, (DWORD)0) == WAIT_TIMEOUT)
		return thr_MUTEX_RET_NOTOWNER;

	CloseHandle(*handle);
	*handle = 0;

#elif defined LINUX
	if (pthread_mutex_destroy(handle) == EBUSY)
		return thr_MUTEX_RET_NOTOWNER;

#elif defined VXWORKS
	if (pthread_mutex_destroy(handle) == EBUSY)
		return thr_MUTEX_RET_NOTOWNER;

#endif

	return 0;
}

int thr_mutex_lock(thr_MUTEX* handle)
{
#if defined WIN32
	if (WaitForSingleObject(*handle, INFINITE) == WAIT_FAILED)
		return thr_MUTEX_RET_LOCKERROR;

#elif defined LINUX
	if (pthread_mutex_lock(handle))
		return thr_MUTEX_RET_LOCKERROR;

#elif defined VXWORKS
	if (pthread_mutex_lock(handle))
		return thr_MUTEX_RET_LOCKERROR;

#endif

	return 0;
}

int thr_mutex_unlock(thr_MUTEX* handle)
{
#if defined WIN32
	if (!ReleaseMutex(*handle))
		return thr_MUTEX_RET_UNLOCKERROR;

#elif defined LINUX
	if (pthread_mutex_unlock(handle))
		return thr_MUTEX_RET_UNLOCKERROR;

#elif defined VXWORKS
	if (pthread_mutex_unlock(handle))
		return thr_MUTEX_RET_UNLOCKERROR;

#endif

	return 0;
}

int thr_sem_init(thr_SEM* handle)
{
#if defined WIN32
	*handle = CreateSemaphore(NULL, 0, 65536, NULL);
	if (NULL == *handle)
		return thr_SEM_RET_CREATEFAILED;

#elif defined LINUX
	if (pthread_mutex_init(&(handle->mutex), NULL))
		return thr_SEM_RET_CREATEFAILED;

	if (pthread_cond_init(&(handle->cond), NULL))
		pthread_mutex_destroy(&(handle->mutex));
		return thr_SEM_RET_CREATEFAILED;

	handle->count = 0;

#elif defined VXWORKS
	if (handle == NULL)
		return thr_SEM_RET_CREATEFAILED;
	memset(handle, 0, sizeof(thr_SEM));

	if (pthread_mutex_init(&(handle->mutex), NULL))
		return thr_SEM_RET_CREATEFAILED;

	if (pthread_cond_init(&(handle->cond), NULL))
		pthread_mutex_destroy(&(handle->mutex));
		return thr_SEM_RET_CREATEFAILED;

	handle->count = 0;

#endif

	return 0;
}

void thr_sem_destroy(thr_SEM* handle)
{
#if defined WIN32
	CloseHandle(*handle);
	*handle = 0;

#elif defined LINUX
	pthread_mutex_destroy(&(handle->mutex));

	pthread_cond_destroy(&(handle->cond));

#elif defined VXWORKS
	pthread_mutex_destroy(&(handle->mutex));

	pthread_cond_destroy(&(handle->cond));

#endif
}


int thr_sem_post(thr_SEM* handle)
{
#if defined WIN32
	ReleaseSemaphore(*handle, 1, NULL);

#elif defined LINUX
	if (pthread_mutex_lock(&(handle->mutex)))
		return thr_SEM_RET_POSTERROR;

	handle->count++;

	if (pthread_mutex_unlock(&(handle->mutex)))
		return thr_SEM_RET_POSTERROR;

	if (pthread_cond_signal(&(handle->cond)))
		return thr_SEM_RET_POSTERROR; 

#elif defined VXWORKS
	if (pthread_mutex_lock(&(handle->mutex)))
		return thr_SEM_RET_POSTERROR;

	handle->count++;

	if (pthread_mutex_unlock(&(handle->mutex)))
		return thr_SEM_RET_POSTERROR;

	if (pthread_cond_signal(&(handle->cond)))
		return thr_SEM_RET_POSTERROR; 

#endif

	return 0;
}


int thr_sem_wait(thr_SEM* handle)
{
#if defined WIN32
	if (WAIT_FAILED == WaitForSingleObject(*handle, INFINITE)) 
		return thr_SEM_RET_WAITERROR;

#elif defined LINUX
	if (pthread_mutex_lock(&(handle->mutex)))
		return thr_SEM_RET_WAITERROR;

	while (handle->count <= 0) {
		if (pthread_cond_wait(&(handle->cond), &(handle->mutex)) 
				&& (errno != EINTR)) {
			break;
		}
	}
	handle->count--;

	if (pthread_mutex_unlock(&(handle->mutex)))
		return thr_SEM_RET_WAITERROR; 

#elif defined VXWORKS
	if (pthread_mutex_lock(&(handle->mutex)))
		return thr_SEM_RET_WAITERROR;

	while (handle->count <= 0) {
		if (pthread_cond_wait(&(handle->cond), &(handle->mutex)) 
				&& (errno != EINTR)) {
			break;
		}
	}
	handle->count--;

	if (pthread_mutex_unlock(&(handle->mutex)))
		return thr_SEM_RET_WAITERROR; 

#endif

	return 0;
}

int thr_sem_timewait(thr_SEM* handle, UINT32 milliseconds)
{
#if defined WIN32
	DWORD dwRet;

	dwRet = WaitForSingleObject(*handle, milliseconds);
	if (WAIT_FAILED == dwRet) 
		return thr_SEM_RET_WAITERROR;

	if (WAIT_TIMEOUT == dwRet)
		return thr_SEM_RET_TIMEOUT;

#elif defined LINUX
	int ret;
	struct timespec ts;
	UINT32 sec, millisec;

	if (pthread_mutex_lock(&(handle->mutex)))
		return thr_SEM_RET_WAITERROR;

	sec = milliseconds / 1000;
	millisec = milliseconds % 1000;
	clock_gettime(CLOCK_REALTIME, &ts);
	ts.tv_sec += sec;
	ts.tv_nsec += millisec * 1000000;

	while (handle->count <= 0) {
		ret = pthread_cond_timedwait(&(handle->cond), &(handle->mutex), &ts); 
		if (ret && (errno != EINTR)) {
			break;
		}
	}

	if (ret) {
		if (pthread_mutex_unlock(&(handle->mutex)))
			return thr_SEM_RET_WAITERROR;

		if (ret == ETIMEDOUT)
			return thr_SEM_RET_TIMEOUT;

		return thr_SEM_RET_WAITERROR;
	}

	handle->count--;

	if (pthread_mutex_unlock(&(handle->mutex)))
		return thr_SEM_RET_WAITERROR; 

#elif defined VXWORKS
	int ret;
	struct timespec ts;
	UINT32 sec, millisec;

	if (pthread_mutex_lock(&(handle->mutex)))
		return thr_SEM_RET_WAITERROR;

	sec = milliseconds / 1000;
	millisec = milliseconds % 1000;
	clock_gettime(CLOCK_REALTIME, &ts);
	ts.tv_sec += sec;
	ts.tv_nsec += millisec * 1000000;

	while (handle->count <= 0) {
		ret = pthread_cond_timedwait(&(handle->cond), &(handle->mutex), &ts); 
		if (ret && (errno != EINTR)) {
			break;
		}
	}

	if (ret) {
		if (pthread_mutex_unlock(&(handle->mutex)))
			return thr_SEM_RET_WAITERROR;

		if (ret == ETIMEDOUT)
			return thr_SEM_RET_TIMEOUT;

		return thr_SEM_RET_WAITERROR;
	}

	handle->count--;

	if (pthread_mutex_unlock(&(handle->mutex)))
		return thr_SEM_RET_WAITERROR; 

#endif

	return 0;
}

thr_THREAD_RET thr_THREAD_CALL thrdproc(void *arg) 
{
	thrdpool_t *pthrdpool = (thrdpool_t *)arg;
	task_t *tasks = pthrdpool->tasktab.ptasks;
	UINT32 idx=0;
	INT32 taskidx = -1;
	UINT32 hpri = 99999;
#if defined LINUX
	pthread_detach(pthread_self());
	pthread_setcanceltype(PTHREAD_CANCEL_ASYNCHRONOUS, NULL);
#endif
	for (;;) 
	{
		thr_sem_wait(&(pthrdpool->thread_sem));

		idx=0;
		taskidx = -1;
		hpri = 99999;
		for (idx = 0; idx < pthrdpool->tasktab.count; idx++) {
			if (tasks[idx].state == WAITING) {
				if (hpri >tasks[idx].pri) {
					hpri = tasks[idx].pri;
					taskidx = idx;
				}
			}
		}
		thr_mutex_lock(&pthrdpool->thrdmutex);
		tasks[taskidx].state = PROCESSING;
		pthrdpool->tasktab.waitcount--;
		pthrdpool->tasktab.proscount++;
		//printf("taskidx=%d, taskid=%d, state=%d, pri=%ld, waitcount=%d \n"
		//, taskidx, tasks[taskidx].taskid, tasks[taskidx].state
		//, tasks[taskidx].pri, pthrdpool->tasktab.waitcount);
		thr_mutex_unlock(&pthrdpool->thrdmutex);


		/* processing area */
		(*tasks[taskidx].thrdcall.thrdfunc)(tasks[taskidx].thrdcall.arg);

		if (tasks[taskidx].thrdexit.thrdfunc != NULL)
			(*tasks[taskidx].thrdexit.thrdfunc)(tasks[taskidx].thrdexit.arg);

		/* free this task resource */
		thr_mutex_lock(&pthrdpool->thrdmutex);
		tasks[taskidx].state = IDLE;
		pthrdpool->tasktab.proscount--;
		tasks[taskidx].thrdcall.thrdfunc = NULL;
		tasks[taskidx].thrdcall.arg = NULL;
		tasks[taskidx].thrdexit.thrdfunc = NULL;
		tasks[taskidx].thrdcall.arg = NULL;
		//printf("free task: taskidx=%d, taskid=%d, pri=%ld, threadid=%ld\n"
		//, taskidx, tasks[taskidx].taskid, tasks[taskidx].pri, pthread_self());
		thr_mutex_unlock(&pthrdpool->thrdmutex);
	}

	return NULL;
}

thrdpool_t *thr_createThrdPool(int maxthrds, int maxtasks, char *plogfile) {
	int idx;
	thrdpool_t *pthrdpool;
	task_t *tasks;
	if ((maxthrds <= 0) || (maxtasks <= 0)) {
		printf("Failed to create threadpool, maxthrds or maxtasks illegal.\n");
		return NULL;
	}
	pthrdpool = calloc(sizeof(thrdpool_t), 1);
	pthrdpool->thrdtab.pthrds = calloc(sizeof(thr_THREAD), maxthrds);
	pthrdpool->thrdtab.count = maxthrds;
	pthrdpool->tasktab.ptasks = calloc(sizeof(task_t), maxtasks);
	tasks = pthrdpool->tasktab.ptasks;
	pthrdpool->tasktab.count = maxtasks;
	#if 0
	if (plogfile == NULL)
		pthrdpool->logfile[0] = '\0';
	else
		strcpy(pthrdpool->logfile, plogfile);
	#endif
	pthrdpool->tasktab.waitcount = 0;
	pthrdpool->tasktab.proscount = 0;
	pthrdpool->tasktab.prino = 0;
	for (idx = 0; idx < maxtasks; idx++) {
		tasks[idx].state = IDLE;
		tasks[idx].pri = 0;
		tasks[idx].taskid = -1;
		tasks[idx].thrdcall.thrdfunc = NULL;
		tasks[idx].thrdcall.arg = NULL;
		tasks[idx].thrdexit.thrdfunc = NULL;
		tasks[idx].thrdcall.arg = NULL;
	}

	thr_mutex_init(&(pthrdpool->thrdmutex));


	thr_sem_init(&(pthrdpool->thread_sem));

	for (idx = 0; idx < maxthrds; idx++) 
		thr_thread_create(&(pthrdpool->thrdtab.pthrds[idx]), thrdproc
		    , (void *)pthrdpool);

	return pthrdpool;
}

int thr_destroyThrdPool(thrdpool_t *pthrdpool) {
	UINT32 idx;
	if(pthrdpool == NULL) 
        return threadpool_invalid;

	for (idx = 0; idx < pthrdpool->thrdtab.count; idx++) {
#ifdef	LINUX
		pthread_cancel(pthrdpool->thrdtab.pthrds[idx]);
#elif  defined WIN32
		TerminateThread(pthrdpool->thrdtab.pthrds[idx],1);
#endif
	}

	/* maybe return error EPERM here, but it doesn't matter. */
	thr_mutex_unlock(&pthrdpool->thrdmutex);        
	free(pthrdpool->thrdtab.pthrds);
	free(pthrdpool->tasktab.ptasks);
	free(pthrdpool);
	pthrdpool = NULL;

	return 0;
}

int thr_add_task(thrdpool_t *pthrdpool, unsigned int taskid, 
                 thrdcall_t thrdcall, thrdcall_t thrdexit) {
	UINT32 idx=0;
	INT32 idleidx = -1;
	task_t *tasks=NULL;
	thr_mutex_lock(&(pthrdpool->thrdmutex));
	/* get first idle task item */
	for (idx = 0; idx < pthrdpool->tasktab.count; idx++) {
		if (pthrdpool->tasktab.ptasks[idx].state == IDLE) {
			idleidx = idx;
			break;
		}
	}
	if (idleidx == -1) {        
		//printf("too many tasks for new task [%d].\n", taskid);
		thr_mutex_unlock(&pthrdpool->thrdmutex);
		return threadpool_queue_full;
	}
	tasks = pthrdpool->tasktab.ptasks;
	tasks[idleidx].taskid = taskid;
	tasks[idleidx].state = WAITING;
	tasks[idleidx].thrdcall.thrdfunc = thrdcall.thrdfunc;
	tasks[idleidx].thrdcall.arg = thrdcall.arg;
	tasks[idleidx].thrdexit.thrdfunc = thrdexit.thrdfunc;
	tasks[idleidx].thrdexit.arg = thrdexit.arg;
	pthrdpool->tasktab.waitcount++;
	/* calculate the priority of the coming task */
	pthrdpool->tasktab.prino++;
	tasks[idleidx].pri = pthrdpool->tasktab.prino;

	thr_sem_post(&(pthrdpool->thread_sem));
	thr_mutex_unlock(&pthrdpool->thrdmutex);
	return 0;
}

