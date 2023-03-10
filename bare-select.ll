; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=riscv32 -verify-machineinstrs < %s \
; RUN:   | FileCheck %s -check-prefix=RV32I
define i32 @bare_select(i1 %a, i32 %b, i32 %c) {
   ; RV32I-LABEL: bare_select:
   ; RV32I:       # %bb.0:
   ; RV32I-NEXT:    andi a0, a0, 1
   ; RV32I-NEXT:    addi a3, zero, 0
   ; RV32I-NEXT:    bne a0, a3, .LBB0_2
   ; RV32I-NEXT:  # %bb.1:
   ; RV32I-NEXT:    addi a1, a2, 0
   ; RV32I-NEXT:  .LBB0_2:
   ; RV32I-NEXT:    addi a0, a1, 0
   ; RV32I-NEXT:    jalr zero, ra, 0
     %1 = select i1 %a, i32 %b, i32 %c
     ret i32 %1
}