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
  mv  x1, zero
  mv  x2, zero
  mv  x3, zero
  mv  x4, zero
  mv  x5, zero
  mv  x6, zero
  mv  x7, zero
  mv  x8, zero
  mv  x9, zero
  mv x10, zero
  mv x11, zero
  mv x12, zero
  mv x13, zero
  mv x14, zero
  mv x15, zero
  mv x16, zero
  mv x17, zero
  mv x18, zero
  mv x19, zero
  mv x20, zero
  mv x21, zero
  mv x22, zero
  mv x23, zero
  mv x24, zero
  mv x25, zero
  mv x26, zero
  mv x27, zero
  mv x28, zero
  mv x29, zero
  mv x30, zero
  mv x31, zero

  # Initialize the stack
  la   sp, _stack_start

_default_handler:
  j _default_handler

.section .text.start
  
_start:
  .global _start

  # jump to main program entry point (argc = argv = 0) 
  addi x10, x0, 0
  addi x11, x0, 0

  jal x1, main




 
