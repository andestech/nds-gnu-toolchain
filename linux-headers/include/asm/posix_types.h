/* SPDX-License-Identifier: GPL-2.0 WITH Linux-syscall-note */
#ifndef _ASM_RISCV_POSIX_TYPES_H
#define _ASM_RISCV_POSIX_TYPES_H

#include <asm/bitsperlong.h>

/*
 * In the generic flow, this file is automatically created if it does not
 * already exist, as indicated by the line.
 * "#include <asm-generic/posix_types.h>"
 *
 * If the file already exists, the automatic creation process will be skipped.
 * Adding architecture-specific types to this file may alter the generic flow,
 * potentially causing type conflicts during the build phase. To avoid this,
 * define a variable to instruct the generic code to skip the re-typedef
 * process.
 */
#if __BITS_PER_LONG == 32
typedef long long		__kernel_off_t;
#define _arch_kernel_off_t	_arch_kernel_off_t;
#endif

/*
 * The "long" type is 4 bytes in RV32 and 8 bytes in RV64.
 *
 * Before adding an architecture specific type:
 * In RV32: __kernel_off_t -> __kernel_long_t -> long (4 byte)
 * In RV64: __kernel_off_t -> __kernel_long_t -> long (8 byte)
 *
 * After adding architecture specific type:
 * In RV32: __kernel_off_t -> long long (8 byte)
 * In RV64: __kernel_off_t -> __kernel_long_t -> long (8 byte)
 *
 * This architecture specific type is only for RV32.
 */

#include <asm-generic/posix_types.h>

#endif /* _ASM_RISCV_POSIX_TYPES_H */
