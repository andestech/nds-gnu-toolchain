/*
 *  linux/arch/nds32/include/asm/ptrace.h
 *
 *  Copyright (C) 1996-2003 Russell King
 *  Copyright (C) 2008 Andes Technology Corporation
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 2 as
 * published by the Free Software Foundation.
 */
#ifndef __ASM_NDS32_PTRACE_H
#define __ASM_NDS32_PTRACE_H

#define PTRACE_GETREGS		12
#define PTRACE_SETREGS		13
#define PTRACE_GETFPREGS	14
#define PTRACE_SETFPREGS	15
#define PTRACE_GETAUREGS	18
#define PTRACE_SETAUREGS	19

#define PTRACE_OLDSETOPTIONS	21

#define PTRACE_GET_THREAD_AREA	22

#ifndef __ASSEMBLY__
/* this struct defines the way the registers are stored on the
   stack during a system call. */

struct pt_regs {
	unsigned long uregs[44];
};
#define NDS32_osp       uregs[43]
#define NDS32_FUCOP_CTL uregs[42]
#define NDS32_lp        uregs[41]
#define NDS32_gp        uregs[40]
#define NDS32_fp        uregs[39]
#define NDS32_r25       uregs[38]
#define NDS32_r24       uregs[37]
#define NDS32_r23       uregs[36]
#define NDS32_r22       uregs[35]
#define NDS32_r21       uregs[34]
#define NDS32_r20       uregs[33]
#define NDS32_r19       uregs[32]
#define NDS32_r18       uregs[31]
#define NDS32_r17       uregs[30]
#define NDS32_r16       uregs[29]
#define NDS32_r15       uregs[28]
#define NDS32_r14       uregs[27]
#define NDS32_r13       uregs[26]
#define NDS32_r12       uregs[25]
#define NDS32_r11       uregs[24]
#define NDS32_r10       uregs[23]
#define NDS32_r9        uregs[22]
#define NDS32_r8        uregs[21]
#define NDS32_r7        uregs[20]
#define NDS32_r6        uregs[19]
#define NDS32_r5        uregs[18]
#define NDS32_r4        uregs[17]
#define NDS32_r3        uregs[16]
#define NDS32_r2        uregs[15]
#define NDS32_r1        uregs[14]
#define NDS32_r0        uregs[13]
#if defined(CONFIG_HWZOL)
#define NDS32_lc        uregs[11]
#define NDS32_le        uregs[10]
#define NDS32_lb        uregs[9]
#endif
#define NDS32_pp1       uregs[8]
#define NDS32_pp0       uregs[7]
#define NDS32_pipc      uregs[6]
#define NDS32_pipsw     uregs[5]
#define NDS32_ORIG_r0   uregs[4]
#define NDS32_sp        uregs[3]
#define NDS32_ipc       uregs[2]
#define NDS32_ipsw      uregs[1]
#define NDS32_ir0       uregs[0]


#endif /* !__ASSEMBLY__ */

#endif /* __ASM_NDS32_PTRACE_H */
