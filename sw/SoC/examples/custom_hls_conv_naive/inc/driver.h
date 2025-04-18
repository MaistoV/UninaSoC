#ifndef __DRIVER_H_
#define __DRIVER_H_

// Inlcudes
#include "xil_io.h"
#include "xkrnl_conv_naive_hw.h"

// Import symbols for peripherals
extern const volatile uint32_t _peripheral_HLS_CONTROL_start;

// Offsets
#define Xkrnl_BASE             ((unsigned int)(&_peripheral_HLS_CONTROL_start))
#define Xkrnl_Control          (Xkrnl_BASE + XKRNL_CONV_NAIVE_CONTROL_ADDR_AP_CTRL)
#define Xkrnl_GIE              (Xkrnl_BASE + XKRNL_CONV_NAIVE_CONTROL_ADDR_GIE)
#define Xkrnl_IER              (Xkrnl_BASE + XKRNL_CONV_NAIVE_CONTROL_ADDR_IER)
#define Xkrnl_ISR              (Xkrnl_BASE + XKRNL_CONV_NAIVE_CONTROL_ADDR_ISR)
#define Xkrnl_AXI_ADDR_I       (Xkrnl_BASE + XKRNL_CONV_NAIVE_CONTROL_ADDR_I_DATA)
#define Xkrnl_AXI_ADDR_W       (Xkrnl_BASE + XKRNL_CONV_NAIVE_CONTROL_ADDR_W_DATA)
#define Xkrnl_AXI_ADDR_O       (Xkrnl_BASE + XKRNL_CONV_NAIVE_CONTROL_ADDR_O_DATA)

#define AP_START                    (0x00000001)
#define AP_DONE                     (0x00000002)
#define AP_IDLE                     (0x00000004)
#define AP_READY                    (0x00000008)
#define AP_CONTINUE                 (0x00000010)
#define AP_AUTORESTART              (0x00000080)
#define AP_INTERRUPT                (0x00000200)

#define AP_START_BIT                (0x00000000)
#define AP_DONE_BIT                 (0x00000001)
#define AP_IDLE_BIT                 (0x00000002)
#define AP_READY_BIT                (0x00000003)
#define AP_CONTINUE_BIT             (0x00000004)
#define AP_AUTORESTART_BIT          (0x00000007)
#define AP_INTERRUPT_BIT            (0x00000009)

// Control
#define XKrnl_conv_naive_EnableAutoRestart() \
    Xil_Out32(Xkrnl_Control, AP_AUTORESTART_BIT)

#define XKrnl_conv_naive_Start() \
    Xil_Out32(Xkrnl_Control, (Xil_In32(Xkrnl_Control) & AP_AUTORESTART) | AP_START)

#define XKrnl_conv_naive_IsDone() \
    Xil_In32(Xkrnl_ISR) & AP_DONE_BIT

#define XKrnl_conv_naive_IsIdle() \
        Xil_In32(Xkrnl_ISR) & AP_IDLE_BIT

#define XKrnl_conv_naive_IsReady() \
            Xil_In32(Xkrnl_ISR) & AP_READY_BIT

// GIE
#define XKrnl_conv_naive_InterruptGlobalEnable() \
    Xil_Out32(Xkrnl_GIE, 0x1)

#define XKrnl_conv_naive_InterruptGlobalDisable() \
    Xil_Out32(Xkrnl_GIE, 0x0)

// ISR
#define XKrnl_conv_naive_InterruptClear_ap_done() \
    Xil_Out32(Xkrnl_ISR, 0x0)

#define XKrnl_conv_naive_InterruptClear_ap_ready() \
    Xil_Out32(Xkrnl_ISR, 0x1)

#define XKrnl_conv_naive_InterruptGetStatus() \
    Xil_In32(Xkrnl_ISR)

// IER
#define XKrnl_conv_naive_InterruptEnable_ap_done() \
    Xil_Out32(Xkrnl_IER (Xil_In32(Xkrnl_IER)) | 0x1)

#define XKrnl_conv_naive_InterruptEnable_ap_ready() \
    Xil_Out32(Xkrnl_IER, (Xil_In32(Xkrnl_IER)) | 0x2)

#define XKrnl_conv_naive_InterruptDisable_ap_done() \
    Xil_Out32(Xkrnl_IER, (Xil_In32(Xkrnl_IER)) & (~0x1))

#define XKrnl_conv_naive_InterruptDisable_ap_ready() \
    Xil_Out32(Xkrnl_IER, (Xil_In32(Xkrnl_IER)) & (~0x2))

#define XKrnl_conv_naive_InterruptGetEnabled() \
    Xil_In32(Xkrnl_IER)

// AXI_MM_ADDR
#define XKrnl_conv_naive_Get_axi_addr_I() \
    Xil_In32(Xkrnl_AXI_ADDR_I)
#define XKrnl_conv_naive_Get_axi_addr_W() \
    Xil_In32(Xkrnl_AXI_ADDR_W)
#define XKrnl_conv_naive_Get_axi_addr_O() \
    Xil_In32(Xkrnl_AXI_ADDR_O)

// NOTE: these might need to be for  uint64_t
#define XKrnl_conv_naive_Set_axi_addr_I(value) \
    Xil_Out32(Xkrnl_AXI_ADDR_I, (uint32_t)value)
#define XKrnl_conv_naive_Set_axi_addr_W(value) \
    Xil_Out32(Xkrnl_AXI_ADDR_W, (uint32_t)value)
#define XKrnl_conv_naive_Set_axi_addr_O(value) \
    Xil_Out32(Xkrnl_AXI_ADDR_O, (uint32_t)value)


#endif // __DRIVER_H