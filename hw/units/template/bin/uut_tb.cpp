#include <stdio.h>
#include <stdlib.h>
#include "Vuut.h"
#include "verilated_vcd_c.h"
#include "verilated.h"

#define CLK_NS 10
#define CYCLES 100000

void tick(int tickcount, Vuut *tb, VerilatedVcdC *tfp);
void trace_init(Vuut *tb, VerilatedVcdC * tfp);

int main(int argc, char **argv){
	
	Vuut * tb = new Vuut;
	VerilatedVcdC * tfp = new VerilatedVcdC;

	unsigned tickcount = 0;
	trace_init(tb,tfp);

	for(int i = 0; i < CYCLES; i++){

		(i == 0) ? tb->rstn_i = 0 : tb->rstn_i = 1;

		tick(++tickcount,tb,tfp);

	}

	delete tb;
	delete tfp;

}

void tick(int tickcount, Vuut *tb, VerilatedVcdC *tfp){
	tb->eval();
	if(tfp) //dump 2ns before the tick
		tfp->dump(tickcount*CLK_NS - 2);
	tb->clk_i = 1;
	tb->eval();
	if(tfp) //Tick every CLK_NS
		tfp->dump(tickcount*CLK_NS);
	tb->clk_i = 0;
	tb->eval();
	if(tfp){ //Trailing edge dump
		tfp->dump(tickcount*CLK_NS+5);
		tfp->flush();
	}
}

void trace_init(Vuut *tb, VerilatedVcdC * tfp){

	Verilated::traceEverOn(true);
	
	tb->trace(tfp,99);
	tfp->open("waves/trace.vcd");
}


