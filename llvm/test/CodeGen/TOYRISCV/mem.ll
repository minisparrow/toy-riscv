define i32 @lb(i8 *%a) nounwind {
; RV32I-LABEL: lb:
; RV32I:       # %bb.0:
; RV32I-NEXT:    lb a1, 0(a0)
; RV32I-NEXT:    lb a0, 1(a0)
; RV32I-NEXT:    jalr zero, ra, 0
  %1 = getelementptr i8, i8* %a, i32 1
  %2 = load i8, i8* %1
  %3 = sext i8 %2 to i32
  ; the unused load will produce an anyext for selection
  %4 = load volatile i8, i8* %a
  ret i32 %3
}
