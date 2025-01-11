# UninaSoC startup file

.section .vector_table, "ax"
.option norvc;

  # According to RISC-V Specification, all entries are jumps to the specific handler.
  # Only the reset handler is defined in this file, while all other handlers points to
  # the default_handler (a loop)

  jal x0, _reset_handler         
  .rept 31
  jal x0, _default_handler
  .endr        

.section .text.handlers

_reset_handler:
  .global _reset_handler

  # Clean all registers
  mv ra, zero
  mv sp, zero
  mv gp, zero
  mv tp, zero
  mv t0, zero
  mv t1, zero
  mv t2, zero
  mv s0, zero
  mv s1, zero
  mv a0, zero
  mv a1, zero
  mv a2, zero
  mv a3, zero
  mv a4, zero
  mv a5, zero
  mv a6, zero
  mv a7, zero
  mv s2, zero
  mv s3, zero
  mv s4, zero
  mv s5, zero
  mv s6, zero
  mv s7, zero
  mv s8, zero
  mv s9, zero
  mv s10, zero
  mv s11, zero
  mv t3, zero
  mv t4, zero
  mv t5, zero
  mv t6, zero

  # Initialize the stack
  la   sp, _stack_start

  # Jump to start function
  j _start

_default_handler:
  j _default_handler

.section .text.start
  
_start:
  .global _start

  # jump to main program entry point (argc = argv = 0) 
  mv a0, zero
  mv a1, zero

  jal ra, main




 
