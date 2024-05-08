// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Tracing implementation internals
#include "verilated_vcd_c.h"
#include "Vtest__Syms.h"


//======================

void Vtest::trace(VerilatedVcdC* tfp, int, int) {
    tfp->spTrace()->addInitCb(&traceInit, __VlSymsp);
    traceRegister(tfp->spTrace());
}

void Vtest::traceInit(void* userp, VerilatedVcd* tracep, uint32_t code) {
    // Callback from tracep->open()
    Vtest__Syms* __restrict vlSymsp = static_cast<Vtest__Syms*>(userp);
    if (!Verilated::calcUnusedSigs()) {
        VL_FATAL_MT(__FILE__, __LINE__, __FILE__,
                        "Turning on wave traces requires Verilated::traceEverOn(true) call before time 0.");
    }
    vlSymsp->__Vm_baseCode = code;
    tracep->module(vlSymsp->name());
    tracep->scopeEscape(' ');
    Vtest::traceInitTop(vlSymsp, tracep);
    tracep->scopeEscape('.');
}

//======================


void Vtest::traceInitTop(void* userp, VerilatedVcd* tracep) {
    Vtest__Syms* __restrict vlSymsp = static_cast<Vtest__Syms*>(userp);
    Vtest* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    {
        vlTOPp->traceInitSub0(userp, tracep);
    }
}

void Vtest::traceInitSub0(void* userp, VerilatedVcd* tracep) {
    Vtest__Syms* __restrict vlSymsp = static_cast<Vtest__Syms*>(userp);
    Vtest* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    const int c = vlSymsp->__Vm_baseCode;
    if (false && tracep && c) {}  // Prevent unused
    // Body
    {
        tracep->declBit(c+1,"rstn_i", false,-1);
        tracep->declBit(c+2,"clk_i", false,-1);
        tracep->declBit(c+3,"a_i", false,-1);
        tracep->declBit(c+4,"bit_o", false,-1);
        tracep->declBit(c+1,"test rstn_i", false,-1);
        tracep->declBit(c+2,"test clk_i", false,-1);
        tracep->declBit(c+3,"test a_i", false,-1);
        tracep->declBit(c+4,"test bit_o", false,-1);
    }
}

void Vtest::traceRegister(VerilatedVcd* tracep) {
    // Body
    {
        tracep->addFullCb(&traceFullTop0, __VlSymsp);
        tracep->addChgCb(&traceChgTop0, __VlSymsp);
        tracep->addCleanupCb(&traceCleanup, __VlSymsp);
    }
}

void Vtest::traceFullTop0(void* userp, VerilatedVcd* tracep) {
    Vtest__Syms* __restrict vlSymsp = static_cast<Vtest__Syms*>(userp);
    Vtest* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    {
        vlTOPp->traceFullSub0(userp, tracep);
    }
}

void Vtest::traceFullSub0(void* userp, VerilatedVcd* tracep) {
    Vtest__Syms* __restrict vlSymsp = static_cast<Vtest__Syms*>(userp);
    Vtest* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
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
