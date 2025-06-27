# Author: Stefano Mercogliano <stefano.mercogliano@unina.it>
# Description:
#     Bootrom code for uninasoc. It is a simple implementation that 
#     do not require stack nor vector table. It just zeroes registers
#     and then loop in an active wait, until the bootrom is reprogrammed
#     with an application specific ZSBL.

.section .text

_default_bootrom:
  .global _default_bootrom

  #####################
  # Registers Cleanup #
  #####################

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

  ############
  # NOP Loop #
  ############

_nop_loop:
  .rept 32
    nop
  .endr
  j _nop_loop





