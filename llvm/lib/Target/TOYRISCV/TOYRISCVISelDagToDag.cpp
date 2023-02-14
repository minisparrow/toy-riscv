#include "TOYRISCVISelDagToDag.h"

using namespace llvm;

TOYRISCVDAGToDAGISel::TOYRISCVDAGToDAGISel(TOYRISCVTargetMachine &TM,
                                           CodeGenOpt::Level OL)
    : SelectionDAGISel(TM, OL), Subtarget(nullptr) {}

StringRef TOYRISCVDAGToDAGISel::getPassName() const {
  return "TOYRISCV DAG->DAG Pattern Instruction Selection";
}
bool TOYRISCVDAGToDAGISel::runOnMachineFunction(MachineFunction &MF) {
  Subtarget = &MF.getSubtarget<TOYRISCVSubtarget>();
  return SelectionDAGISel::runOnMachineFunction(MF);
}

void TOYRISCVDAGToDAGISel::Select(SDNode *N) {
  if (N->isMachineOpcode()) {
    LLVM_DEBUG(dbgs() << "== "; N->dump(CurDAG); dbgs() << "\n");
    N->setNodeId(-1);
    return;
  }

  SelectCode(N);
}

// vim: set ts=2 sw=2 sts=2:
