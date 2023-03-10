; RUN: llc -mtriple=riscv32 -verify-machineinstrs < %s \
; RUN:   | FileCheck %s -check-prefix=RV32I

; Materializing constants

define i32 @zero() nounwind {
; RV32I-LABEL: zero:
; RV32I:       # %bb.0:
; RV32I-NEXT:    addi a0, zero, 0
; RV32I-NEXT:    jalr zero, ra, 0
  ret i32 0
}

define i32 @pos_small() nounwind {
; RV32I-LABEL: pos_small:
; RV32I:       # %bb.0:
; RV32I-NEXT:    addi a0, zero, 2047
; RV32I-NEXT:    jalr zero, ra, 0
  ret i32 2047
}

define i32 @neg_small() nounwind {
; RV32I-LABEL: neg_small:
; RV32I:       # %bb.0:
; RV32I-NEXT:    addi a0, zero, -2048
; RV32I-NEXT:    jalr zero, ra, 0
  ret i32 -2048
}

define i32 @pos_i32() nounwind {
; RV32I-LABEL: pos_i32:
; RV32I:       # %bb.0:
; RV32I-NEXT:    lui a0, 423811
; RV32I-NEXT:    addi a0, a0, -1297
; RV32I-NEXT:    jalr zero, ra, 0
  ret i32 1735928559
}

define i32 @neg_i32() nounwind {
; RV32I-LABEL: neg_i32:
; RV32I:       # %bb.0:
; RV32I-NEXT:    lui a0, 912092
; RV32I-NEXT:    addi a0, a0, -273
; RV32I-NEXT:    jalr zero, ra, 0
  ret i32 -559038737
}
