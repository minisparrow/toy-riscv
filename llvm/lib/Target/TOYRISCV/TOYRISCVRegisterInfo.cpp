#include "TOYRISCVRegisterInfo.h"
#include "TOYRISCV.h"
#include "TOYRISCVSubtarget.h"

#define GET_REGINFO_TARGET_DESC
#include "TOYRISCVGenRegisterInfo.inc"

using namespace llvm;

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
  for (const reg : ReservedCPURegs) {
    Reserved.set(reg);
  }

  return Reserved;
}

void TOYRISCVRegisterInfo::eliminateFrameIndex(
    MachineBasicBlock::iterator II, int SPAdj, unsigned FIOperandNum,
    RegScavenger *RS = nullptr) const {
  // TODO
}

// vim: set ts=2 sw=2 sts=2:
