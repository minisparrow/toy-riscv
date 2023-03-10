; RUN: llc -mtriple=riscv32 -verify-machineinstrs < %s \
; RUN:   | FileCheck -check-prefix=RV32I %s

define void @foo(i32 %a, i32 *%b, i1 %c) {
; RV32I-LABEL: foo:
; RV32I:       # %bb.0:
; RV32I-NEXT:    lw a3, 0(a1)
; RV32I-NEXT:    beq a3, a0, .LBB0_12
; RV32I-NEXT:    jal zero, .LBB0_1
; RV32I-NEXT:  .LBB0_1: # %test2
; RV32I-NEXT:    lw a3, 0(a1)
; RV32I-NEXT:    bne a3, a0, .LBB0_12
; RV32I-NEXT:    jal zero, .LBB0_2
; RV32I-NEXT:  .LBB0_2: # %test3
; RV32I-NEXT:    lw a3, 0(a1)
; RV32I-NEXT:    blt a3, a0, .LBB0_12
; RV32I-NEXT:    jal zero, .LBB0_3
; RV32I-NEXT:  .LBB0_3: # %test4
; RV32I-NEXT:    lw a3, 0(a1)
; RV32I-NEXT:    bge a3, a0, .LBB0_12
; RV32I-NEXT:    jal zero, .LBB0_4
; RV32I-NEXT:  .LBB0_4: # %test5
; RV32I-NEXT:    lw a3, 0(a1)
; RV32I-NEXT:    bltu a3, a0, .LBB0_12
; RV32I-NEXT:    jal zero, .LBB0_5
; RV32I-NEXT:  .LBB0_5: # %test6
; RV32I-NEXT:    lw a3, 0(a1)
; RV32I-NEXT:    bgeu a3, a0, .LBB0_12
; RV32I-NEXT:    jal zero, .LBB0_6
; RV32I-NEXT:  .LBB0_6: # %test7
; RV32I-NEXT:    lw a3, 0(a1)
; RV32I-NEXT:    blt a0, a3, .LBB0_12
; RV32I-NEXT:    jal zero, .LBB0_7
; RV32I-NEXT:  .LBB0_7: # %test8
; RV32I-NEXT:    lw a3, 0(a1)
; RV32I-NEXT:    bge a0, a3, .LBB0_12
; RV32I-NEXT:    jal zero, .LBB0_8
; RV32I-NEXT:  .LBB0_8: # %test9
; RV32I-NEXT:    lw a3, 0(a1)
; RV32I-NEXT:    bltu a0, a3, .LBB0_12
; RV32I-NEXT:    jal zero, .LBB0_9
; RV32I-NEXT:  .LBB0_9: # %test10
; RV32I-NEXT:    lw a3, 0(a1)
; RV32I-NEXT:    bgeu a0, a3, .LBB0_12
; RV32I-NEXT:    jal zero, .LBB0_10
; RV32I-NEXT:  .LBB0_10: # %test11
; RV32I-NEXT:    lw a0, 0(a1)
; RV32I-NEXT:    andi a0, a2, 1
; RV32I-NEXT:    bne a0, zero, .LBB0_12
; RV32I-NEXT:    jal zero, .LBB0_11
; RV32I-NEXT:  .LBB0_11: # %test12
; RV32I-NEXT:    lw a0, 0(a1)
; RV32I-NEXT:  .LBB0_12: # %end
; RV32I-NEXT:    jalr zero, ra, 0

  %val1 = load volatile i32, i32* %b
  %tst1 = icmp eq i32 %val1, %a
  br i1 %tst1, label %end, label %test2

test2:
  %val2 = load volatile i32, i32* %b
  %tst2 = icmp ne i32 %val2, %a
  br i1 %tst2, label %end, label %test3

test3:
  %val3 = load volatile i32, i32* %b
  %tst3 = icmp slt i32 %val3, %a
  br i1 %tst3, label %end, label %test4

test4:
  %val4 = load volatile i32, i32* %b
  %tst4 = icmp sge i32 %val4, %a
  br i1 %tst4, label %end, label %test5

test5:
  %val5 = load volatile i32, i32* %b
  %tst5 = icmp ult i32 %val5, %a
  br i1 %tst5, label %end, label %test6

test6:
  %val6 = load volatile i32, i32* %b
  %tst6 = icmp uge i32 %val6, %a
  br i1 %tst6, label %end, label %test7

; Check for condition codes that don't have a matching instruction

test7:
  %val7 = load volatile i32, i32* %b
  %tst7 = icmp sgt i32 %val7, %a
  br i1 %tst7, label %end, label %test8

test8:
  %val8 = load volatile i32, i32* %b
  %tst8 = icmp sle i32 %val8, %a
  br i1 %tst8, label %end, label %test9

test9:
  %val9 = load volatile i32, i32* %b
  %tst9 = icmp ugt i32 %val9, %a
  br i1 %tst9, label %end, label %test10

test10:
  %val10 = load volatile i32, i32* %b
  %tst10 = icmp ule i32 %val10, %a
  br i1 %tst10, label %end, label %test11

; Check the case of a branch where the condition was generated in another
; function

test11:
  %val11 = load volatile i32, i32* %b
  br i1 %c, label %end, label %test12

test12:
  %val12 = load volatile i32, i32* %b
  br label %end

end:
  ret void
}
