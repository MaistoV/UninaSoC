#include <stdio.h>
#include <stdlib.h>
#include "Vtest.h"
#include "verilated_vcd_c.h"
#include "verilated.h"

#define CLK_NS 20
#define CYCLES 1000

void tick(int tickcount, Vtest *tb, VerilatedVcdC *tfp);
void trace_init(Vtest *tb, VerilatedVcdC * tfp);

int main(int argc, char **argv){
	
	Vtest * tb = new Vtest;
	VerilatedVcdC * tfp = new VerilatedVcdC;

	unsigned tickcount = 0;
	trace_init(tb,tfp);

	printf("Welcome to Verilator Simulation\n\n");

	for(int i = 0; i < CYCLES; i++){

		(i == 0) ? tb->rstn_i = 0 : tb->rstn_i = 1;

		tick(++tickcount,tb,tfp);

	}

	delete tb;
	delete tfp;

}

void tick(int tickcount, Vtest *tb, VerilatedVcdC *tfp){
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

void trace_init(Vtest *tb, VerilatedVcdC * tfp){

	Verilated::traceEverOn(true);
	
	tb->trace(tfp,99);
	tfp->open("waves/trace.vcd");
}


