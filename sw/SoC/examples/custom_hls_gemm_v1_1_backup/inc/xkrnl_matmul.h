// ==============================================================
// Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2024.2 (64-bit)
// Tool Version Limit: 2024.11
// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
//
// ==============================================================
#ifndef XKRNL_MATMUL_H
#define XKRNL_MATMUL_H

#ifdef __cplusplus
extern "C" {
#endif

/***************************** Include Files *********************************/
// #ifndef __linux__
#include "xil_types.h"
#include "xil_assert.h"
#include "xstatus.h"
#include "xil_io.h"
// #else
// #include <stdint.h>
// #include <assert.h>
// #include <dirent.h>
// #include <fcntl.h>
// #include <stdio.h>
// #include <stdlib.h>
// #include <string.h>
// #include <sys/mman.h>
// #include <unistd.h>
// #include <stddef.h>
// #endif
#include "xkrnl_matmul_hw.h"

/**************************** Type Definitions ******************************/
// #ifdef __linux__
// typedef uint8_t u8;
// typedef uint16_t u16;
// typedef uint32_t u32;
// typedef uint64_t u64;
// #else
typedef struct {
#ifdef SDT
    char *Name;
#else
    u16 DeviceId;
#endif
    u64 Control_BaseAddress;
} XKrnl_MATMUL_Config;
// #endif

typedef struct {
    u64 Control_BaseAddress;
    u32 IsReady;
} XKrnl_MATMUL;

typedef u32 word_type;

/***************** Macros (Inline Functions) Definitions *********************/
// #ifndef __linux__
#define XKrnl_MATMUL_WriteReg(BaseAddress, RegOffset, Data) \
    Xil_Out32((BaseAddress) + (RegOffset), (u32)(Data))
#define XKrnl_MATMUL_ReadReg(BaseAddress, RegOffset) \
    Xil_In32((BaseAddress) + (RegOffset))
// #else
// #define XKrnl_MATMUL_WriteReg(BaseAddress, RegOffset, Data) \
//     *(volatile u32*)((BaseAddress) + (RegOffset)) = (u32)(Data)
// #define XKrnl_MATMUL_ReadReg(BaseAddress, RegOffset) \
//     *(volatile u32*)((BaseAddress) + (RegOffset))

// #define Xil_AssertVoid(expr)    assert(expr)
// #define Xil_AssertNonvoid(expr) assert(expr)

// #define XST_SUCCESS             0
// #define XST_DEVICE_NOT_FOUND    2
// #define XST_OPEN_DEVICE_FAILED  3
// #define XIL_COMPONENT_IS_READY  1
// #endif

/************************** Function Prototypes *****************************/
// #ifndef __linux__
// #ifdef SDT
int XKrnl_MATMUL_Initialize(XKrnl_MATMUL *InstancePtr, UINTPTR BaseAddress);
XKrnl_MATMUL_Config* XKrnl_MATMUL_LookupConfig(UINTPTR BaseAddress);
// #else
// int XKrnl_MATMUL_Initialize(XKrnl_MATMUL *InstancePtr, u16 DeviceId);
// XKrnl_MATMUL_Config* XKrnl_MATMUL_LookupConfig(u16 DeviceId);
// #endif
int XKrnl_MATMUL_CfgInitialize(XKrnl_MATMUL *InstancePtr, XKrnl_MATMUL_Config *ConfigPtr);
// #else
// int XKrnl_MATMUL_Initialize(XKrnl_MATMUL *InstancePtr, const char* InstanceName);
// int XKrnl_MATMUL_Release(XKrnl_MATMUL *InstancePtr);
// #endif

void XKrnl_MATMUL_Start(XKrnl_MATMUL *InstancePtr);
u32 XKrnl_MATMUL_IsDone(XKrnl_MATMUL *InstancePtr);
u32 XKrnl_MATMUL_IsIdle(XKrnl_MATMUL *InstancePtr);
u32 XKrnl_MATMUL_IsReady(XKrnl_MATMUL *InstancePtr);
void XKrnl_MATMUL_Continue(XKrnl_MATMUL *InstancePtr);
void XKrnl_MATMUL_EnableAutoRestart(XKrnl_MATMUL *InstancePtr);
void XKrnl_MATMUL_DisableAutoRestart(XKrnl_MATMUL *InstancePtr);

void XKrnl_MATMUL_Set_A(XKrnl_MATMUL *InstancePtr, u64 Data);
u64 XKrnl_MATMUL_Get_A(XKrnl_MATMUL *InstancePtr);
void XKrnl_MATMUL_Set_B(XKrnl_MATMUL *InstancePtr, u64 Data);
u64 XKrnl_MATMUL_Get_B(XKrnl_MATMUL *InstancePtr);
void XKrnl_MATMUL_Set_out_r(XKrnl_MATMUL *InstancePtr, u64 Data);
u64 XKrnl_MATMUL_Get_out_r(XKrnl_MATMUL *InstancePtr);
void XKrnl_MATMUL_Set_size(XKrnl_MATMUL *InstancePtr, u32 Data);
u32 XKrnl_MATMUL_Get_size(XKrnl_MATMUL *InstancePtr);

void XKrnl_MATMUL_InterruptGlobalEnable(XKrnl_MATMUL *InstancePtr);
void XKrnl_MATMUL_InterruptGlobalDisable(XKrnl_MATMUL *InstancePtr);
void XKrnl_MATMUL_InterruptEnable(XKrnl_MATMUL *InstancePtr, u32 Mask);
void XKrnl_MATMUL_InterruptDisable(XKrnl_MATMUL *InstancePtr, u32 Mask);
void XKrnl_MATMUL_InterruptClear(XKrnl_MATMUL *InstancePtr, u32 Mask);
u32 XKrnl_MATMUL_InterruptGetEnabled(XKrnl_MATMUL *InstancePtr);
u32 XKrnl_MATMUL_InterruptGetStatus(XKrnl_MATMUL *InstancePtr);

#ifdef __cplusplus
}
#endif

#endif
