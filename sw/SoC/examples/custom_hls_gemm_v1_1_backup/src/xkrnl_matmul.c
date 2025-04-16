// // // ==============================================================
// // // Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2024.2 (64-bit)
// // // Tool Version Limit: 2024.11
// // // Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// // // Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// // //
// // // ==============================================================
// // /***************************** Include Files *********************************/
// #include "xkrnl_matmul.h"

// // /************************** Function Implementation *************************/
// // // #ifndef __linux__
// // int XKrnl_MATMUL_CfgInitialize(XKrnl_MATMUL *InstancePtr, XKrnl_MATMUL_Config *ConfigPtr) {XKrnl_MATMUL_Start
// //     Xil_AssertNonvoid(InstancePtr != NULL);
// //     Xil_AssertNonvoid(ConfigPtr != NULL);

// //     InstancePtr->Control_BaseAddress = ConfigPtr->Control_BaseAddress;
// //     InstancePtr->IsReady = XIL_COMPONENT_IS_READY;

// //     return XST_SUCCESS;
// // }
// // // #endif

// void XKrnl_MATMUL_Start(XKrnl_MATMUL *InstancePtr) {
//     u32 Data;

//     Xil_AssertVoid(InstancePtr != NULL);
//     Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

//     Data = XKrnl_MATMUL_ReadReg(InstancePtr->Control_BaseAddress, XKRNL_MATMUL_CONTROL_ADDR_AP_CTRL) & 0x80;
//     XKrnl_MATMUL_WriteReg(InstancePtr->Control_BaseAddress, XKRNL_MATMUL_CONTROL_ADDR_AP_CTRL, Data | 0x01);
// }

// // u32 XKrnl_MATMUL_IsDone(XKrnl_MATMUL *InstancePtr) {
// //     u32 Data;

// //     Xil_AssertNonvoid(InstancePtr != NULL);
// //     Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

// //     Data = XKrnl_MATMUL_ReadReg(InstancePtr->Control_BaseAddress, XKRNL_MATMUL_CONTROL_ADDR_AP_CTRL);
// //     return (Data >> 1) & 0x1;
// // }

// // u32 XKrnl_MATMUL_IsIdle(XKrnl_MATMUL *InstancePtr) {
// //     u32 Data;

// //     Xil_AssertNonvoid(InstancePtr != NULL);
// //     Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

// //     Data = XKrnl_MATMUL_ReadReg(InstancePtr->Control_BaseAddress, XKRNL_MATMUL_CONTROL_ADDR_AP_CTRL);
// //     return (Data >> 2) & 0x1;
// // }

// // u32 XKrnl_MATMUL_IsReady(XKrnl_MATMUL *InstancePtr) {
// //     u32 Data;

// //     Xil_AssertNonvoid(InstancePtr != NULL);
// //     Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

// //     Data = XKrnl_MATMUL_ReadReg(InstancePtr->Control_BaseAddress, XKRNL_MATMUL_CONTROL_ADDR_AP_CTRL);
// //     // check ap_start to see if the pcore is ready for next input
// //     return !(Data & 0x1);
// // }

// // void XKrnl_MATMUL_Continue(XKrnl_MATMUL *InstancePtr) {
// //     u32 Data;

// //     Xil_AssertVoid(InstancePtr != NULL);
// //     Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

// //     Data = XKrnl_MATMUL_ReadReg(InstancePtr->Control_BaseAddress, XKRNL_MATMUL_CONTROL_ADDR_AP_CTRL) & 0x80;
// //     XKrnl_MATMUL_WriteReg(InstancePtr->Control_BaseAddress, XKRNL_MATMUL_CONTROL_ADDR_AP_CTRL, Data | 0x10);
// // }

// void XKrnl_MATMUL_EnableAutoRestart(XKrnl_MATMUL *InstancePtr) {
//     Xil_AssertVoid(InstancePtr != NULL);
//     Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

//     XKrnl_MATMUL_WriteReg(InstancePtr->Control_BaseAddress, XKRNL_MATMUL_CONTROL_ADDR_AP_CTRL, 0x80);
// }

// // void XKrnl_MATMUL_DisableAutoRestart(XKrnl_MATMUL *InstancePtr) {
// //     Xil_AssertVoid(InstancePtr != NULL);
// //     Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

// //     XKrnl_MATMUL_WriteReg(InstancePtr->Control_BaseAddress, XKRNL_MATMUL_CONTROL_ADDR_AP_CTRL, 0);
// // }

// // // void XKrnl_MATMUL_Set_A(XKrnl_MATMUL *InstancePtr, u64 Data) {
// // //     Xil_AssertVoid(InstancePtr != NULL);
// // //     Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

// // //     XKrnl_MATMUL_WriteReg(InstancePtr->Control_BaseAddress, XKRNL_MATMUL_CONTROL_ADDR_A_DATA, (u32)(Data));
// // //     XKrnl_MATMUL_WriteReg(InstancePtr->Control_BaseAddress, XKRNL_MATMUL_CONTROL_ADDR_A_DATA + 4, (u32)(Data >> 32));
// // // }

// // // u64 XKrnl_MATMUL_Get_A(XKrnl_MATMUL *InstancePtr) {
// // //     u64 Data;

// // //     Xil_AssertNonvoid(InstancePtr != NULL);
// // //     Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

// // //     Data = XKrnl_MATMUL_ReadReg(InstancePtr->Control_BaseAddress, XKRNL_MATMUL_CONTROL_ADDR_A_DATA);
// // //     Data += (u64)XKrnl_MATMUL_ReadReg(InstancePtr->Control_BaseAddress, XKRNL_MATMUL_CONTROL_ADDR_A_DATA + 4) << 32;
// // //     return Data;
// // // }

// // // void XKrnl_MATMUL_Set_B(XKrnl_MATMUL *InstancePtr, u64 Data) {
// // //     Xil_AssertVoid(InstancePtr != NULL);
// // //     Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

// // //     XKrnl_MATMUL_WriteReg(InstancePtr->Control_BaseAddress, XKRNL_MATMUL_CONTROL_ADDR_B_DATA, (u32)(Data));
// // //     XKrnl_MATMUL_WriteReg(InstancePtr->Control_BaseAddress, XKRNL_MATMUL_CONTROL_ADDR_B_DATA + 4, (u32)(Data >> 32));
// // // }

// // // u64 XKrnl_MATMUL_Get_B(XKrnl_MATMUL *InstancePtr) {
// // //     u64 Data;

// // //     Xil_AssertNonvoid(InstancePtr != NULL);
// // //     Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

// // //     Data = XKrnl_MATMUL_ReadReg(InstancePtr->Control_BaseAddress, XKRNL_MATMUL_CONTROL_ADDR_B_DATA);
// // //     Data += (u64)XKrnl_MATMUL_ReadReg(InstancePtr->Control_BaseAddress, XKRNL_MATMUL_CONTROL_ADDR_B_DATA + 4) << 32;
// // //     return Data;
// // // }

// // // void XKrnl_MATMUL_Set_out_r(XKrnl_MATMUL *InstancePtr, u64 Data) {
// // //     Xil_AssertVoid(InstancePtr != NULL);
// // //     Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

// // //     XKrnl_MATMUL_WriteReg(InstancePtr->Control_BaseAddress, XKRNL_MATMUL_CONTROL_ADDR_OUT_R_DATA, (u32)(Data));
// // //     XKrnl_MATMUL_WriteReg(InstancePtr->Control_BaseAddress, XKRNL_MATMUL_CONTROL_ADDR_OUT_R_DATA + 4, (u32)(Data >> 32));
// // // }

// // // u64 XKrnl_MATMUL_Get_out_r(XKrnl_MATMUL *InstancePtr) {
// // //     u64 Data;

// // //     Xil_AssertNonvoid(InstancePtr != NULL);
// // //     Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

// // //     Data = XKrnl_MATMUL_ReadReg(InstancePtr->Control_BaseAddress, XKRNL_MATMUL_CONTROL_ADDR_OUT_R_DATA);
// // //     Data += (u64)XKrnl_MATMUL_ReadReg(InstancePtr->Control_BaseAddress, XKRNL_MATMUL_CONTROL_ADDR_OUT_R_DATA + 4) << 32;
// // //     return Data;
// // // }

// // // void XKrnl_MATMUL_Set_size(XKrnl_MATMUL *InstancePtr, u32 Data) {
// // //     Xil_AssertVoid(InstancePtr != NULL);
// // //     Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

// // //     XKrnl_MATMUL_WriteReg(InstancePtr->Control_BaseAddress, XKRNL_MATMUL_CONTROL_ADDR_SIZE_DATA, Data);
// // // }

// // // u32 XKrnl_MATMUL_Get_size(XKrnl_MATMUL *InstancePtr) {
// // //     u32 Data;

// // //     Xil_AssertNonvoid(InstancePtr != NULL);
// // //     Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

// // //     Data = XKrnl_MATMUL_ReadReg(InstancePtr->Control_BaseAddress, XKRNL_MATMUL_CONTROL_ADDR_SIZE_DATA);
// // //     return Data;
// // // }

// // void XKrnl_MATMUL_InterruptGlobalEnable(XKrnl_MATMUL *InstancePtr) {
// //     Xil_AssertVoid(InstancePtr != NULL);
// //     Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

// //     XKrnl_MATMUL_WriteReg(InstancePtr->Control_BaseAddress, XKRNL_MATMUL_CONTROL_ADDR_GIE, 1);
// // }

// // void XKrnl_MATMUL_InterruptGlobalDisable(XKrnl_MATMUL *InstancePtr) {
// //     Xil_AssertVoid(InstancePtr != NULL);
// //     Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

// //     XKrnl_MATMUL_WriteReg(InstancePtr->Control_BaseAddress, XKRNL_MATMUL_CONTROL_ADDR_GIE, 0);
// // }

// // void XKrnl_MATMUL_InterruptEnable(XKrnl_MATMUL *InstancePtr, u32 Mask) {
// //     u32 Register;

// //     Xil_AssertVoid(InstancePtr != NULL);
// //     Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

// //     Register =  XKrnl_MATMUL_ReadReg(InstancePtr->Control_BaseAddress, XKRNL_MATMUL_CONTROL_ADDR_IER);
// //     XKrnl_MATMUL_WriteReg(InstancePtr->Control_BaseAddress, XKRNL_MATMUL_CONTROL_ADDR_IER, Register | Mask);
// // }

// // void XKrnl_MATMUL_InterruptDisable(XKrnl_MATMUL *InstancePtr, u32 Mask) {
// //     u32 Register;

// //     Xil_AssertVoid(InstancePtr != NULL);
// //     Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

// //     Register =  XKrnl_MATMUL_ReadReg(InstancePtr->Control_BaseAddress, XKRNL_MATMUL_CONTROL_ADDR_IER);
// //     XKrnl_MATMUL_WriteReg(InstancePtr->Control_BaseAddress, XKRNL_MATMUL_CONTROL_ADDR_IER, Register & (~Mask));
// // }

// // void XKrnl_MATMUL_InterruptClear(XKrnl_MATMUL *InstancePtr, u32 Mask) {
// //     Xil_AssertVoid(InstancePtr != NULL);
// //     Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

// //     XKrnl_MATMUL_WriteReg(InstancePtr->Control_BaseAddress, XKRNL_MATMUL_CONTROL_ADDR_ISR, Mask);
// // }

// // u32 XKrnl_MATMUL_InterruptGetEnabled(XKrnl_MATMUL *InstancePtr) {
// //     Xil_AssertNonvoid(InstancePtr != NULL);
// //     Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

// //     return XKrnl_MATMUL_ReadReg(InstancePtr->Control_BaseAddress, XKRNL_MATMUL_CONTROL_ADDR_IER);
// // }

// // u32 XKrnl_MATMUL_InterruptGetStatus(XKrnl_MATMUL *InstancePtr) {
// //     Xil_AssertNonvoid(InstancePtr != NULL);
// //     Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

// //     return XKrnl_MATMUL_ReadReg(InstancePtr->Control_BaseAddress, XKRNL_MATMUL_CONTROL_ADDR_ISR);
// // }

