define i32 @andi(i32 %a) nounwind {
; RV32I-LABEL: andi:
; RV32I:       # %bb.0:
; RV32I-NEXT:    andi a0, a0, 6
; RV32I-NEXT:    jalr zero, ra, 0
  %1 = and i32 %a, 6
  ret i32 %1
}
