; Check load and store to a global
@G = global i32 0

define i32 @lw_sw_global(i32 %a) nounwind {
; TODO: the addi should be folded in to the lw/sw operations
; RV32I-LABEL: lw_sw_global:
; RV32I:       # %bb.0:
; RV32I-NEXT:    lui a1, %hi(G)
; RV32I-NEXT:    addi a2, a1, %lo(G)
; RV32I-NEXT:    lw a1, 0(a2)
; RV32I-NEXT:    sw a0, 0(a2)
; RV32I-NEXT:    lui a2, %hi(G+36)
; RV32I-NEXT:    addi a2, a2, %lo(G+36)
; RV32I-NEXT:    lw a3, 0(a2)
; RV32I-NEXT:    sw a0, 0(a2)
; RV32I-NEXT:    addi a0, a1, 0
; RV32I-NEXT:    jalr zero, ra, 0
  %1 = load volatile i32, i32* @G
  store i32 %a, i32* @G
  %2 = getelementptr i32, i32* @G, i32 9
  %3 = load volatile i32, i32* %2
  store i32 %a, i32* %2
  ret i32 %1
}

