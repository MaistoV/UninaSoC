/******************************************************************************
* Copyright (c) 2010 - 2021 Xilinx, Inc.  All rights reserved.
* Copyright (c) 2022 - 2023 Advanced Micro Devices, Inc. All Rights Reserved.
* SPDX-License-Identifier: MIT
******************************************************************************/

/*****************************************************************************/
/**
*
* @file xil_types.h
*
* @addtogroup common_types Basic Data types for Xilinx&reg; Software IP
*
* The xil_types.h file contains basic types for Xilinx software IP. These data types
* are applicable for all processors supported by Xilinx.
* @{
* <pre>
* MODIFICATION HISTORY:
*
* Ver   Who    Date   Changes
* ----- ---- -------- -------------------------------------------------------
* 1.00a hbm  07/14/09 First release
* 3.03a sdm  05/30/11 Added Xuint64 typedef and XUINT64_MSW/XUINT64_LSW macros
* 5.00 	pkp  05/29/14 Made changes for 64 bit architecture
*	srt  07/14/14 Use standard definitions from stdint.h and stddef.h
*		      Define LONG and ULONG datatypes and mask values
* 7.00  mus  01/07/19 Add cpp extern macro
* 7.1   aru  08/19/19 Shift the value in UPPER_32_BITS only if it
*                     is 64-bit processor
* 8.1   dp   12/23/22 Updated UINTPTR and INTPTR to point to 64bit data types
*                     incase of microblaze 32-bit with extended address enabled
* 9.0   ml   14/04/23 Add parenthesis on sub-expression to fix misra-c violation.
* </pre>
*
******************************************************************************/

/**
 *@cond nocomments
 */
#ifndef XIL_TYPES_H	/* prevent circular inclusions */
#define XIL_TYPES_H	/* by using protection macros */

#include <stdint.h>

typedef uint64_t UINTPTR;

typedef uint8_t u8;
typedef uint16_t u16;
typedef uint32_t u32;
typedef uint64_t u64;

#endif	/* end of protection macro */
/**
 *@endcond
 */
/**
* @} End of "addtogroup common_types".
*/
