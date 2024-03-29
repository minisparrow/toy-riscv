@addr = global i8* null
define void @test_blockaddress() nounwind {
; RV32I-LABEL: test_blockaddress:
; RV32I:       # %bb.0:
; RV32I-NEXT:    sw ra, 0(s0)
; RV32I-NEXT:    lui a0, %hi(addr)
; RV32I-NEXT:    addi a0, a0, %lo(addr)
; RV32I-NEXT:    lui a1, %hi(.Ltmp0)
; RV32I-NEXT:    addi a1, a1, %lo(.Ltmp0)
; RV32I-NEXT:    sw a1, 0(a0)
; RV32I-NEXT:    lw a0, 0(a0)
; RV32I-NEXT:    jalr zero, a0, 0
; RV32I-NEXT:  .Ltmp0: # Block address taken
; RV32I-NEXT:  .LBB0_1: # %block
; RV32I-NEXT:    lw ra, 0(s0)
; RV32I-NEXT:    jalr zero, ra, 0
  store volatile i8* blockaddress(@test_blockaddress, %block), i8** @addr
  %val = load volatile i8*, i8** @addr
  indirectbr i8* %val, [label %block]

block:
  ret void
}
