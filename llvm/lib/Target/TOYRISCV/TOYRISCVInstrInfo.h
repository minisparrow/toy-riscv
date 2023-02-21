// #ifndef TOYRISCVINSTRINFO_H_INCLUDED
// #define TOYRISCVINSTRINFO_H_INCLUDED
#ifndef LLVM_LIB_TARGET_TOYRISCV_INSTRINFO_H 

#define LLVM_LIB_TARGET_TOYRISCV_INSTRINFO_H

// #include "TOYRISCV.h"
#include "TOYRISCVRegisterInfo.h"
#include "llvm/CodeGen/TargetInstrInfo.h"
#include "llvm/IR/DiagnosticInfo.h"

#define GET_INSTRINFO_HEADER
#define GET_INSTRINFO_OPERAND_ENUM
#include "TOYRISCVGenInstrInfo.inc"

namespace llvm {

class TOYRISCVSubtarget;

class TOYRISCVInstrInfo : public TOYRISCVGenInstrInfo {
  // virtual void anchor();

public:
  explicit TOYRISCVInstrInfo();

  // TODO
  void copyPhysReg(MachineBasicBlock &MBB, MachineBasicBlock::iterator MBBI,
                   const DebugLoc &DL, MCRegister DstReg, MCRegister SrcReg,
                   bool KillSrc) const override;
};

} // namespace llvm

#endif // TOYRISCVINSTRINFO_H_INCLUDED

// vim: set ts=2 sw=2 sts=2:
