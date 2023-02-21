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

void TOYRISCVDAGToDAGISel::Select(SDNode *Node) {
  if (Node->isMachineOpcode()) {
    LLVM_DEBUG(dbgs() << "== "; Node->dump(CurDAG); dbgs() << "\n");
    Node->setNodeId(-1);
    return;
  }

  // Instruction selection not handled by the auto-generated tablegen selection should be handled here.

  unsigned Opcode =  Node->getOpcode();
  MVT XLenVT = Subtarget->getXLenVT();
  SDLoc DL(Node);
  MVT VT = Node->getSimpleValueType(0);

  switch (Opcode)
  {
     case ISD::FrameIndex: {
       SDValue Imm = CurDAG->getTargetConstant(0, DL, XLenVT);
       int FI = cast<FrameIndexSDNode>(Node)->getIndex();
       SDValue TFI = CurDAG->getTargetFrameIndex(FI, VT);
       ReplaceNode(Node, CurDAG->getMachineNode(TOYRISCV::ADDI, DL, VT, TFI, Imm));
       return;
     }

     default:
       break;
     }

  SelectCode(Node);
}

// vim: set ts=2 sw=2 sts=2:
