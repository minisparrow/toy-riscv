#if !defined TOYRISCVINSTRINFO_H_INCLUDED
#define TOYRISCVINSTRINFO_H_INCLUDED

#include "TOYRISCVRegisterInfo.h"
#include "llvm/CodeGen/TargetInstrInfo.h"

#define GET_INSTRINFO_HEADER
#include "TOYRISCVGenInstrInfo.inc"

namespace llvm {

class TOYRISCVInstrInfo : public TOYRISCVGenInstrInfo {
  // TODO
};

} // namespace llvm

#endif // TOYRISCVINSTRINFO_H_INCLUDED

// vim: set ts=2 sw=2 sts=2:
