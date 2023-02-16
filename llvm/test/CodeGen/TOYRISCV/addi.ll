; RUN: llc -mtriple=riscv32 -verify-machineinstrs < %s \
; RUN:   | FileCheck %s -check-prefix=RV32I

; Register-immediate instructions

define i32 @addi(i32 %a) nounwind {
; RV32I-LABEL: addi:
; RV32I:       # %bb.0:
; rv32I-NEXT:    addi a0, a0, 1
; RV32I-NEXT:    jalr zero, ra, 0
; TODO: check support for materialising larger constants
  %1 = add i32 %a, 1
  ret i32 %1
}
