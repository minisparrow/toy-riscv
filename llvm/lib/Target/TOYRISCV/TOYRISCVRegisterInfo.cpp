#include "TOYRISCVRegisterInfo.h"
#include "TOYRISCV.h"
#include "TOYRISCVSubtarget.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/Type.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/raw_ostream.h"

#define GET_REGINFO_TARGET_DESC
#include "TOYRISCVGenRegisterInfo.inc"

using namespace llvm;

TOYRISCVRegisterInfo::TOYRISCVRegisterInfo(TOYRISCVSubtarget const &ST,
                                           unsigned HwMode)
    : TOYRISCVGenRegisterInfo(TOYRISCV::RA, 0, 0, 0, HwMode), Subtarget(ST) {}

MCPhysReg const *
TOYRISCVRegisterInfo::getCalleeSavedRegs(MachineFunction const *MF) const {
  // This constant was generated by tablegen from TOYRISCVCallingConv.td
  return CSR_LP32_SaveList;
}

uint32_t const *
TOYRISCVRegisterInfo::getCallPreservedMask(MachineFunction const &MF,
                                           CallingConv::ID) const {
  return CSR_LP32_RegMask;
}

BitVector
TOYRISCVRegisterInfo::getReservedRegs(MachineFunction const &MF) const {
  constexpr uint16_t ReservedCPURegs[] = {TOYRISCV::ZERO, TOYRISCV::RA,
                                          TOYRISCV::FP,   TOYRISCV::SP,
                                          TOYRISCV::GP,   TOYRISCV::TP};
  BitVector Reserved(getNumRegs());
  for (auto const reg : ReservedCPURegs) {
    Reserved.set(reg);
  }

  return Reserved;
}

void TOYRISCVRegisterInfo::eliminateFrameIndex(MachineBasicBlock::iterator II,
                                               int SPAdj, unsigned FIOperandNum,
                                               RegScavenger *RS) const {
  // TODO
  // report_fatal_error("Subroutines not supported yet");
  // TODO: this implementation is a temporary placeholder which does just
  // enough to allow other aspects of code generation to be tested
  assert(SPAdj == 0 && "Unexpected non-zero SPAdj value");
  MachineInstr &MI = *II;
  MachineFunction &MF = *MI.getParent()->getParent();
  const TargetFrameLowering *TFI = MF.getSubtarget().getFrameLowering();
  DebugLoc DL = MI.getDebugLoc();
  Register FrameReg = getFrameRegister(MF);
  int FrameIndex = MI.getOperand(FIOperandNum).getIndex();
  StackOffset Offset = TFI->getFrameIndexReference(MF, FrameIndex, FrameReg);
  Offset += StackOffset::getFixed(MI.getOperand(FIOperandNum + 1).getImm());
  assert(TFI->hasFP(MF) && "eliminateFrameIndex currently requires hasFP");
  // Offsets must be directly encoded in a 12-bit immediate field
  if (!isInt<12>(Offset.getFixed())) {
    report_fatal_error(
        "Frame offsets outside of the signed 12-bit range not supported");
  }
  MI.getOperand(FIOperandNum).ChangeToRegister(FrameReg, false);
  MI.getOperand(FIOperandNum + 1).ChangeToImmediate(Offset.getFixed());
}

Register
TOYRISCVRegisterInfo::getFrameRegister(MachineFunction const &MF) const {
  const TargetFrameLowering *TFI = getFrameLowering(MF);
  return TFI->hasFP(MF) ? TOYRISCV::FP : TOYRISCV::SP;
}

// vim: set ts=2 sw=2 sts=2:
