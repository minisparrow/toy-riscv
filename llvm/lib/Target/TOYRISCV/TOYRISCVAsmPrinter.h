#if !defined TOYRISCVASMPRINTER_H_INCLUDED
#define TOYRISCVASMPRINTER_H_INCLUDED

#include "TOYRISCVSubtarget.h"
#include "TOYRISCVTargetMachine.h"
#include "llvm/CodeGen/AsmPrinter.h"
#include "llvm/MC/MCStreamer.h"
#include "llvm/Target/TargetMachine.h"

namespace llvm {

class TOYRISCVAsmPrinter : public AsmPrinter {
public:
  TOYRISCVAsmPrinter(TargetMachine &TM, std::unique_ptr<MCStreamer> Streamer);

  virtual StringRef getPassName() const override;
  void emitInstruction(const MachineInstr *MI);
  bool emitPseudoExpansionLowering(MCStreamer &OutStreamer,
                                   const MachineInstr *MI);
};

} // namespace llvm

#endif // TOYRISCVASMPRINTER_H_INCLUDED

// vim: set ts=2 sw=2 sts=2:
