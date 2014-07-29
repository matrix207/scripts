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
 * @file platform_def.h
 * @brief platform define header file
 */

#ifndef _PLATFORM_DEF_H_
#define _PLATFORM_DEF_H_

#include <stdio.h>

#if defined WIN32
	#define _CRT_SECURE_NO_DEPRECATE

	// define in windows.h, for reduce header include, speed up build process
	#ifndef WIN32_LEAN_AND_MEAN
	#define WIN32_LEAN_AND_MEAN		
	#endif

	#include <windows.h>
	#include <winsock2.h>
	#pragma comment(lib, "ws2_32.lib")
	#include <process.h>
	#include <malloc.h>
	#include <assert.h>
	#include <time.h>

#elif defined LINUX
	//#warning "*********** Do Linux platform compile *************"
	/* TCP/IP */
	#include <sys/socket.h>
	#include <sys/select.h> 
	#include <sys/time.h>
	#include <netinet/in.h>
	#include <arpa/inet.h> 

	#include <sys/ioctl.h>
	#include <net/if.h>
	
	/* Thread */
	#include <sched.h>
	#include <pthread.h>
	/* Malloc,Free */
	#include <stdlib.h>
	#include <string.h>
	#include <unistd.h>
	#include <fcntl.h>
	#include <errno.h>
	#include <assert.h>
	/* sign */
	#include <stdio.h>
	#include <time.h>
	#include <signal.h>

#elif defined VXWORKS
	#include <time.h>
	/* TCP/IP */
	#include <sockLib.h>
	#include <selectLib.h> 

	#include <netinet/in.h>
	#include <netinet/tcp.h>
	#include <arpa/inet.h> 
	/* Thread */
	#include <sched.h>
	#include <taskLib.h>
	#include <pthread.h>
	/* Malloc,Free */
	#include <stdlib.h>
	#include <string.h>
	#include <unistd.h>
	#include <ioLib.h>
	#include <ioctl.h>
	#include <errno.h>
	#include <assert.h>
#endif

#if defined WIN32
#pragma message("defeind UINT32")
	typedef int BOOL;
	typedef signed char INT8, *PINT8;
	typedef unsigned char UINT8, *PUINT8;

	typedef signed short INT16, *PINT16;
	typedef unsigned short UINT16, *PUINT16;

	typedef signed int INT32, *PINT32;
	typedef unsigned int UINT32, *PUINT32;

#elif defined LINUX

	typedef int BOOL;
	typedef signed char INT8, *PINT8;
	typedef signed char CHAR, *PCHAR;
	typedef unsigned char UINT8, *PUINT8;
	typedef unsigned char UCHAR, *PUCHAR;

	typedef signed short INT16, *PINT16;
	typedef signed short SHORT, *PSHORT;
	typedef unsigned short UINT16, *PUINT16;
	typedef unsigned short USHORT, *PUSHORT;

	typedef signed int INT32, *PINT32;
	typedef signed int LONG, *PLONG;
	typedef unsigned int UINT32, *PUINT32;
	typedef unsigned int ULONG, *PULONG;

#elif defined VXWORKS

	typedef signed char *PINT8;
	typedef signed char *PCHAR;
	typedef unsigned char *PUINT8;
	typedef unsigned char *PUCHAR;

	typedef signed short *PINT16;
	typedef signed short *PSHORT;
	typedef unsigned short *PUINT16;
	typedef unsigned short *PUSHORT;

	typedef signed int *PINT32;
	typedef signed int *PLONG;
	typedef unsigned int *PUINT32;
	typedef unsigned int *PULONG;

#endif

#ifndef NULL
#define NULL 0
#endif

#ifndef TRUE
#define TRUE 1
#endif

#ifndef FALSE
#define FALSE 0
#endif

#if defined WIN32

#define FUNC_NAME __FUNCTION__
#define SLEEP(a) Sleep((a)*1000)

#elif defined LINUX

#define FUNC_NAME __func__
#define SLEEP(a) sleep(a)

#endif

#define ENTER_FUNC() {printf("+ %s\n", FUNC_NAME);}
#define EXIT_FUNC()  {printf("- %s\n", FUNC_NAME);}

#endif // _PLATFORM_DEF_H_

