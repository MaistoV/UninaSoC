// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Tracing implementation internals
#include "verilated_vcd_c.h"
#include "Vmux__Syms.h"


//======================

void Vmux::trace(VerilatedVcdC* tfp, int, int) {
    tfp->spTrace()->addInitCb(&traceInit, __VlSymsp);
    traceRegister(tfp->spTrace());
}

void Vmux::traceInit(void* userp, VerilatedVcd* tracep, uint32_t code) {
    // Callback from tracep->open()
    Vmux__Syms* __restrict vlSymsp = static_cast<Vmux__Syms*>(userp);
    if (!Verilated::calcUnusedSigs()) {
        VL_FATAL_MT(__FILE__, __LINE__, __FILE__,
                        "Turning on wave traces requires Verilated::traceEverOn(true) call before time 0.");
    }
    vlSymsp->__Vm_baseCode = code;
    tracep->module(vlSymsp->name());
    tracep->scopeEscape(' ');
    Vmux::traceInitTop(vlSymsp, tracep);
    tracep->scopeEscape('.');
}

//======================


void Vmux::traceInitTop(void* userp, VerilatedVcd* tracep) {
    Vmux__Syms* __restrict vlSymsp = static_cast<Vmux__Syms*>(userp);
    Vmux* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    {
        vlTOPp->traceInitSub0(userp, tracep);
    }
}

void Vmux::traceInitSub0(void* userp, VerilatedVcd* tracep) {
    Vmux__Syms* __restrict vlSymsp = static_cast<Vmux__Syms*>(userp);
    Vmux* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    const int c = vlSymsp->__Vm_baseCode;
    if (false && tracep && c) {}  // Prevent unused
    // Body
    {
        tracep->declBit(c+1,"rstn_i", false,-1);
        tracep->declBit(c+2,"clk_i", false,-1);
        tracep->declBit(c+3,"a_i", false,-1);
        tracep->declBit(c+4,"bit_o", false,-1);
        tracep->declBit(c+1,"mux rstn_i", false,-1);
        tracep->declBit(c+2,"mux clk_i", false,-1);
        tracep->declBit(c+3,"mux a_i", false,-1);
        tracep->declBit(c+4,"mux bit_o", false,-1);
    }
}

void Vmux::traceRegister(VerilatedVcd* tracep) {
    // Body
    {
        tracep->addFullCb(&traceFullTop0, __VlSymsp);
        tracep->addChgCb(&traceChgTop0, __VlSymsp);
        tracep->addCleanupCb(&traceCleanup, __VlSymsp);
    }
}

void Vmux::traceFullTop0(void* userp, VerilatedVcd* tracep) {
    Vmux__Syms* __restrict vlSymsp = static_cast<Vmux__Syms*>(userp);
    Vmux* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    {
        vlTOPp->traceFullSub0(userp, tracep);
    }
}

void Vmux::traceFullSub0(void* userp, VerilatedVcd* tracep) {
    Vmux__Syms* __restrict vlSymsp = static_cast<Vmux__Syms*>(userp);
    Vmux* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    vluint32_t* const oldp = tracep->oldp(vlSymsp->__Vm_baseCode);
    if (false && oldp) {}  // Prevent unused
    // Body
    {
        tracep->fullBit(oldp+1,(vlTOPp->rstn_i));
        tracep->fullBit(oldp+2,(vlTOPp->clk_i));
        tracep->fullBit(oldp+3,(vlTOPp->a_i));
        tracep->fullBit(oldp+4,(vlTOPp->bit_o));
    }
}
