/*
 *  linux/arch/nds32/include/asm/byteorder.h
 *  Copyright (C) 2008 Andes Technology Corporation
 */

#ifndef __NDS32_BYTEORDER_H__
#define __NDS32_BYTEORDER_H__

#ifdef __NDS32_EB__
#include <linux/byteorder/big_endian.h>
#else
#include <linux/byteorder/little_endian.h>
#endif

#endif /* __NDS32_BYTEORDER_H__ */
