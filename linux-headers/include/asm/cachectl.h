/*
 * This file is subject to the terms and conditions of the GNU General Public
 * License.  See the file "COPYING" in the main directory of this archive
 * for more details.
 *
 * Copyright (C) 1994, 1995, 1996 by Ralf Baechle
 */
#ifndef	_ASM_CACHECTL
#define	_ASM_CACHECTL

/*
 * Options for cacheflush system call
 */
#define	ICACHE	0		/* flush instruction cache        */
#define	DCACHE	1		/* writeback and flush data cache */
#define	BCACHE	2		/* flush instruction cache + writeback and flush data cache */


#endif	/* _ASM_CACHECTL */
