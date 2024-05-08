// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Tracing implementation internals
#include "verilated_vcd_c.h"
#include "Vtest__Syms.h"


void Vtest::traceChgTop0(void* userp, VerilatedVcd* tracep) {
    Vtest__Syms* __restrict vlSymsp = static_cast<Vtest__Syms*>(userp);
    Vtest* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Variables
    if (VL_UNLIKELY(!vlSymsp->__Vm_activity)) return;
    // Body
    {
        vlTOPp->traceChgSub0(userp, tracep);
    }
}

void Vtest::traceChgSub0(void* userp, VerilatedVcd* tracep) {
    Vtest__Syms* __restrict vlSymsp = static_cast<Vtest__Syms*>(userp);
    Vtest* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    vluint32_t* const oldp = tracep->oldp(vlSymsp->__Vm_baseCode + 1);
    if (false && oldp) {}  // Prevent unused
    // Body
    {
        tracep->chgBit(oldp+0,(vlTOPp->rstn_i));
        tracep->chgBit(oldp+1,(vlTOPp->clk_i));
        tracep->chgBit(oldp+2,(vlTOPp->a_i));
        tracep->chgBit(oldp+3,(vlTOPp->bit_o));
    }
}

void Vtest::traceCleanup(void* userp, VerilatedVcd* /*unused*/) {
    Vtest__Syms* __restrict vlSymsp = static_cast<Vtest__Syms*>(userp);
    Vtest* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    {
        vlSymsp->__Vm_activity = false;
        vlTOPp->__Vm_traceActivity[0U] = 0U;
    }
}
