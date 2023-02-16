
// RISCV 32-bit C return-value convention.
def RetCC_RISCV32 : CallingConv<[CCIfType<[i32, i64], CCAssignToReg<[A0, A1]>>]>;

// RISCV 32-bit C Calling convention.
def CC_RISCV32 : CallingConv<[
  // Promote i8/i16 args to i32
  CCIfType<[ i8, i16 ], CCPromoteToType<i32>>,

  // All arguments get passed in integer registers if there is space.
  CCIfType<[i32, i64], CCAssignToReg<[ A0, A1, A2, A3, A4, A5, A6, A7]>>,

  // Could be assigned to the stack in 8-byte aligned units, but unsupported
  CCAssignToStack<8, 8>
]>;

// ra, sp, fp(s0), s1..s11 are callee-saved registers. Reger spec p.137
def CSR_LP32 : CalleeSavedRegs<(add RA, SP, FP, S1, (sequence "S%u", 2, 11))>;