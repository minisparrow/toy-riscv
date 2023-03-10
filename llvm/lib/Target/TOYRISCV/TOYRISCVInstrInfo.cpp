#include "TOYRISCVInstrInfo.h"
#include "TOYRISCV.h"
#include "TOYRISCVSubtarget.h"
#include "TOYRISCVTargetMachine.h"
#include "llvm/ADT/STLExtras.h"
#include "llvm/ADT/SmallVector.h"
#include "llvm/Analysis/MemoryLocation.h"
#include "llvm/CodeGen/LiveIntervals.h"
#include "llvm/CodeGen/LiveVariables.h"
#include "llvm/CodeGen/MachineFunctionPass.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/CodeGen/RegisterScavenging.h"
#include "llvm/MC/MCInstBuilder.h"
#include "llvm/MC/TargetRegistry.h"
#include "llvm/Support/ErrorHandling.h"

using namespace llvm;

#define GET_INSTRINFO_CTOR_DTOR
#define GET_INSTRINFO_NAMED_OPS
#include "TOYRISCVGenInstrInfo.inc"

// void TOYRISCVInstrInfo::anchor() {}

TOYRISCVInstrInfo::TOYRISCVInstrInfo()
    : TOYRISCVGenInstrInfo(TOYRISCV::ADJCALLSTACKDOWN,
                           TOYRISCV::ADJCALLSTACKUP)
                           {}

void TOYRISCVInstrInfo::copyPhysReg(MachineBasicBlock &MBB,
                                    MachineBasicBlock::iterator MBBI,
                                    const DebugLoc &DL, MCRegister DstReg,
                                    MCRegister SrcReg, bool KillSrc) const {
  assert(TOYRISCV::GPRRegClass.contains(DstReg, SrcReg) &&
         "Impossible reg-to-reg copy");

  BuildMI(MBB, MBBI, DL, get(TOYRISCV::ADDI), DstReg)
      .addReg(SrcReg, getKillRegState(KillSrc))
      .addImm(0);
  return; 
}
// vim: set ts=2 sw=2 sts=2:

const MCInstrDesc &TOYRISCVInstrInfo::getBrCond(TOYRISCVCC::CondCode CC) const {
  switch (CC) {
  default:
    llvm_unreachable("Unknown condition code!");
  case TOYRISCVCC::COND_EQ:
    return get(TOYRISCV::BEQ);
  case TOYRISCVCC::COND_NE:
    return get(TOYRISCV::BNE);
  case TOYRISCVCC::COND_LT:
    return get(TOYRISCV::BLT);
  case TOYRISCVCC::COND_GE:
    return get(TOYRISCV::BGE);
  case TOYRISCVCC::COND_LTU:
    return get(TOYRISCV::BLTU);
  case TOYRISCVCC::COND_GEU:
    return get(TOYRISCV::BGEU);
  }
}