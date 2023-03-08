Toy RISC-V LLVM Backend
=======================

Yet another RISC-V LLVM Backend. This is a project for learning how LLVM backend works and what RISC-V architecture is
by reimplementing the official LLVM's RISC-V backend.

## References

- Official RISC-V backend (LLVM 14.0.6): https://github.com/llvm/llvm-project/tree/f28c006a5895fc0e329fe15fead81e37457cb1d1/llvm/lib/Target/RISCV
- RISC-V specification: https://riscv.org/technical/specifications/
  - v20191213 (PDF): https://github.com/riscv/riscv-isa-manual/releases/download/Ratified-IMAFDQC/riscv-spec-20191213.pdf
- RISC-V Assembly Manual: https://github.com/riscv-non-isa/riscv-asm-manual/blob/master/riscv-asm.md
- Writing an LLVM Backend: https://llvm.org/docs/WritingAnLLVMBackend.html
  - Basic Steps: https://llvm.org/docs/WritingAnLLVMBackend.html#basic-steps

## Getting started

Clone this repository:

```sh
git clone --recursive https://github.com/rhysd/toy-riscv-backend.git
```

Setup LLVM:

```sh
cd /path/to/toy-riscv-backend
./setup.bash
cd ./llvm-project/llvm
mkdir ./build && cd ./build
cmake -G Ninja -DCMAKE_BUILD_TYPE=Debug -DLLVM_TARGETS_TO_BUILD="X86;TOYRISCV;RISCV" -DLLVM_ENABLE_PROJECTS="clang;libcxx;libcxxabi" ..
ninja
```

[setup.bash](./setup.bash) links all sources in [llvm/](./llvm) to [llvm-project/llvm/](./llvm-project/llvm) so that our
backend is built as a part of `llc` compiler.

Setup RISC-V toolchain:

```sh
docker build . -t riscvback
docker run -it --rm -v $(pwd):/app riscvback /bin/bash
```

RISC-V toolchain like `riscv64-unknown-elf-gcc` or `spike` are available in the Docker container.

## Related projects

- Toy RISC-V 32bit CPU written in Chisel: https://github.com/rhysd/riscv32-cpu-chisel

## Random notes

### How to compile and run C sources with RISCV backend

Compile sources.

Setting triple as `--target=riscv64-unknonw-linux-gnu` is necessary to emit LLVM IR targetting 64bit RISC-V processor.
`-march` may not be necessary, but ensure that CPU arch is `rv64g`. It emits `source.bc`.

```sh
./llvm-project/llvm/build/bin/clang --target=riscv64-unknown-linux-gnu -march=rv64g -emit-llvm -c source.c
```

Compile LLVM bitcode to assembly code.

Set CPU arch to `-march=riscv64`. Default value of `-mcpu` is `generic-v64` so it is not necessary but here we ensure it.
`-mattr` specifies what CPU excentions can be used. In this example, we enable 'd' extension by adding `+d`.
It emits `source.s`.

```sh
./llvm-project/llvm/build/bin/llc -march=riscv64 -mcpu=generic-rv64 -mattr=+d -filetype=asm source.bc
```

Check the generated assembly code. The `.attribute 5` is the attribute representing CPU arch. Check the CPU arch
supports all features you need.

```asm
	.text
	.attribute	4, 16
	.attribute	5, "rv64i2p0_f2p0_d2p0"
	.file	"source.c"
	.globl	main
	.p2align	2
	.type	main,@function
main:
...
```

When no feature is enabled, the CPU arch will be `rv64i2p0`. If the assembly code tries to use a feature which is not
enabled by the processor, the following GCC command reports an error like below:

```
source.s:10: Error: ilp32d/lp64d ABI can't be used when d extension isn't supported
```

Finally compile the assembly code to an object file and run it via Spike simulator on Docker container.

```sh
riscv64-unknown-elf-gcc source.s -lc -o source.o
spike pk source.o
```

Note that compiling to an object file from LLVM bitcode via `llc` with `-filetype=obj` does not work.

### How to compile C sources to assembly with our own TOYRISCV backend

Compile to LLVM bitcode using Clang with `riscv64-unknown-elf` target.

```sh
./llvm-project/llvm/build/bin/clang --target=riscv64-unknown-elf -O3 hello.c -c -emit-llvm -o hello.bc
```

Then compile the bitcode to RISC-V 64bit assembly using our own TOYRISCV backend.

```sh
./llvm-project/llvm/build/bin/llc -debug -march=toyriscv64 -filetype=asm hello.bc -o hello.S
```

## License

This project is licensed under [the MIT license](./LICENSE.txt).

# Knowledge Notes

SelectionDAG related

- [x] SDTypeProfile
- [x] SDTypeConstraint
- [x] PatFrag
- [x] SDNodeXForm

- [x] let usesCustomInserter = 1


## Selection DAG Type Profile definitions.

These use the constraints defined above to describe the type requirements of
the various nodes.  These are not hard coded into tblgen, allowing targets to
add their own if needed.

## SDTypeProfile

SDTypeProfile - This profile describes the type requirements of a Selection
DAG node.

```
class SDTypeProfile<int numresults, int numoperands,
                    list<SDTypeConstraint> constraints> {
  int NumResults = numresults;
  int NumOperands = numoperands;
  list<SDTypeConstraint> Constraints = constraints;
}
```

## Selection DAG Type Constraint definitions.

```
class SDTypeConstraint<int opnum> {
  int OperandNum = opnum;
}

// SDTCisInt - The specified operand has integer type.
class SDTCisInt<int OpNum> : SDTypeConstraint<OpNum>;

// SDTCisFP - The specified operand has floating-point type.
class SDTCisFP<int OpNum> : SDTypeConstraint<OpNum>;

// SDTCisSameAs - The two specified operands have identical types.
class SDTCisSameAs<int OpNum, int OtherOp> : SDTypeConstraint<OpNum> {
  int OtherOperandNum = OtherOp;
}
```

### Builtin profiles.

```
def SDTIntLeaf: SDTypeProfile<1, 0, [SDTCisInt<0>]>;         // for 'imm'.
def SDTFPLeaf : SDTypeProfile<1, 0, [SDTCisFP<0>]>;          // for 'fpimm'.
def SDTPtrLeaf: SDTypeProfile<1, 0, [SDTCisPtrTy<0>]>;       // for '&g'.
def SDTOther  : SDTypeProfile<1, 0, [SDTCisVT<0, OtherVT>]>; // for 'vt'.
def SDTUNDEF  : SDTypeProfile<1, 0, []>;                     // for 'undef'.
def SDTUnaryOp  : SDTypeProfile<1, 1, []>;                   // for bitconvert.

def SDTIntBinOp : SDTypeProfile<1, 2, [     // add, and, or, xor, udiv, etc.
  SDTCisSameAs<0, 1>, SDTCisSameAs<0, 2>, SDTCisInt<0>
]>;
```

## Selection DAG Node Transformation Functions.

Selection DAG Node Transformation Functions.

This mechanism allows targets to manipulate nodes in the output DAG once a
match has been formed.  This is typically used to manipulate immediate
values.

```
class SDNodeXForm<SDNode opc, code xformFunction> {
  SDNode Opcode = opc;
  code XFormFunction = xformFunction;
}

def NOOP_SDNodeXForm : SDNodeXForm<imm, [{}]>;
```

## PatFrags

PatFrags - Represents a set of pattern fragments.  Each single fragment
can match something on the DAG, from a single node to multiple nested other
fragments.   The whole set of fragments matches if any of the single
fragments match.  This allows e.g. matching and "add with overflow" and
a regular "add" with the same fragment set.

```
class PatFrags<dag ops, list<dag> frags, code pred = [{}],
               SDNodeXForm xform = NOOP_SDNodeXForm> : SDPatternOperator {
  dag Operands = ops;
  list<dag> Fragments = frags;
  code PredicateCode = pred;
  code GISelPredicateCode = [{}];
  code ImmediateCode = [{}];
  SDNodeXForm OperandTransform = xform;

  // When this is set, the PredicateCode may refer to a constant Operands
  // vector which contains the captured nodes of the DAG, in the order listed
  // by the Operands field above.
  //
  // This is useful when Fragments involves associative / commutative
  // operators: a single piece of code can easily refer to all operands even
  // when re-associated / commuted variants of the fragment are matched.
  bit PredicateCodeUsesOperands = false;

  // Define a few pre-packaged predicates. This helps GlobalISel import
  // existing rules from SelectionDAG for many common cases.
  // They will be tested prior to the code in pred and must not be used in
  // ImmLeaf and its subclasses.

  // Is the desired pre-packaged predicate for a load?
  bit IsLoad = ?;
  // Is the desired pre-packaged predicate for a store?
  bit IsStore = ?;
  // Is the desired pre-packaged predicate for an atomic?
  bit IsAtomic = ?;

  // cast<LoadSDNode>(N)->getAddressingMode() == ISD::UNINDEXED;
  // cast<StoreSDNode>(N)->getAddressingMode() == ISD::UNINDEXED;
  bit IsUnindexed = ?;

  // cast<LoadSDNode>(N)->getExtensionType() != ISD::NON_EXTLOAD
  bit IsNonExtLoad = ?;
  // cast<LoadSDNode>(N)->getExtensionType() == ISD::EXTLOAD;
  bit IsAnyExtLoad = ?;
  // cast<LoadSDNode>(N)->getExtensionType() == ISD::SEXTLOAD;
  bit IsSignExtLoad = ?;
  // cast<LoadSDNode>(N)->getExtensionType() == ISD::ZEXTLOAD;
  bit IsZeroExtLoad = ?;
  // !cast<StoreSDNode>(N)->isTruncatingStore();
  // cast<StoreSDNode>(N)->isTruncatingStore();
  bit IsTruncStore = ?;

  // cast<MemSDNode>(N)->getAddressSpace() ==
  // If this empty, accept any address space.
  list<int> AddressSpaces = ?;

  // cast<MemSDNode>(N)->getAlignment() >=
  // If this is empty, accept any alignment.
  int MinAlignment = ?;

  // cast<AtomicSDNode>(N)->getOrdering() == AtomicOrdering::Monotonic
  bit IsAtomicOrderingMonotonic = ?;
  // cast<AtomicSDNode>(N)->getOrdering() == AtomicOrdering::Acquire
  bit IsAtomicOrderingAcquire = ?;
  // cast<AtomicSDNode>(N)->getOrdering() == AtomicOrdering::Release
  bit IsAtomicOrderingRelease = ?;
  // cast<AtomicSDNode>(N)->getOrdering() == AtomicOrdering::AcquireRelease
  bit IsAtomicOrderingAcquireRelease = ?;
  // cast<AtomicSDNode>(N)->getOrdering() == AtomicOrdering::SequentiallyConsistent
  bit IsAtomicOrderingSequentiallyConsistent = ?;

  // isAcquireOrStronger(cast<AtomicSDNode>(N)->getOrdering())
  // !isAcquireOrStronger(cast<AtomicSDNode>(N)->getOrdering())
  bit IsAtomicOrderingAcquireOrStronger = ?;

  // isReleaseOrStronger(cast<AtomicSDNode>(N)->getOrdering())
  // !isReleaseOrStronger(cast<AtomicSDNode>(N)->getOrdering())
  bit IsAtomicOrderingReleaseOrStronger = ?;

  // cast<LoadSDNode>(N)->getMemoryVT() == MVT::<VT>;
  // cast<StoreSDNode>(N)->getMemoryVT() == MVT::<VT>;
  ValueType MemoryVT = ?;
  // cast<LoadSDNode>(N)->getMemoryVT().getScalarType() == MVT::<VT>;
  // cast<StoreSDNode>(N)->getMemoryVT().getScalarType() == MVT::<VT>;
  ValueType ScalarMemoryVT = ?;
}

// PatFrag - A version of PatFrags matching only a single fragment.
class PatFrag<dag ops, dag frag, code pred = [{}],
              SDNodeXForm xform = NOOP_SDNodeXForm>
  : PatFrags<ops, [frag], pred, xform>;

// OutPatFrag is a pattern fragment that is used as part of an output pattern
// (not an input pattern). These do not have predicates or transforms, but are
// used to avoid repeated subexpressions in output patterns.
class OutPatFrag<dag ops, dag frag>
 : PatFrag<ops, frag, [{}], NOOP_SDNodeXForm>;

// PatLeaf's are pattern fragments that have no operands.  This is just a helper
// to define immediates and other common things concisely.
class PatLeaf<dag frag, code pred = [{}], SDNodeXForm xform = NOOP_SDNodeXForm>
 : PatFrag<(ops), frag, pred, xform>;


// ImmLeaf is a pattern fragment with a constraint on the immediate.  The
// constraint is a function that is run on the immediate (always with the value
// sign extended out to an int64_t) as Imm.  For example:
//
//  def immSExt8 : ImmLeaf<i16, [{ return (char)Imm == Imm; }]>;
//
// this is a more convenient form to match 'imm' nodes in than PatLeaf and also
// is preferred over using PatLeaf because it allows the code generator to
// reason more about the constraint.
//
// If FastIsel should ignore all instructions that have an operand of this type,
// the FastIselShouldIgnore flag can be set.  This is an optimization to reduce
// the code size of the generated fast instruction selector.
class ImmLeaf<ValueType vt, code pred, SDNodeXForm xform = NOOP_SDNodeXForm,
              SDNode ImmNode = imm>
  : PatFrag<(ops), (vt ImmNode), [{}], xform> {
  let ImmediateCode = pred;
  bit FastIselShouldIgnore = false;

  // Is the data type of the immediate an APInt?
  bit IsAPInt = false;

  // Is the data type of the immediate an APFloat?
  bit IsAPFloat = false;
}

// Convenience wrapper for ImmLeaf to use timm/TargetConstant instead
// of imm/Constant.
class TImmLeaf<ValueType vt, code pred, SDNodeXForm xform = NOOP_SDNodeXForm,
  SDNode ImmNode = timm> : ImmLeaf<vt, pred, xform, ImmNode>;

// An ImmLeaf except that Imm is an APInt. This is useful when you need to
// zero-extend the immediate instead of sign-extend it.
//
// Note that FastISel does not currently understand IntImmLeaf and will not
// generate code for rules that make use of it. As such, it does not make sense
// to replace ImmLeaf with IntImmLeaf. However, replacing PatLeaf with an
// IntImmLeaf will allow GlobalISel to import the rule.
class IntImmLeaf<ValueType vt, code pred, SDNodeXForm xform = NOOP_SDNodeXForm>
    : ImmLeaf<vt, pred, xform> {
  let IsAPInt = true;
  let FastIselShouldIgnore = true;
}

```

### Example

1.
(select (setcc lhs, rhs, cc), truev, falsev)
-> (riscvisd::select_cc lhs, rhs, cc, truev, falsev)

2.
(select condv, truev, falsev)
-> (riscvisd::select_cc condv, zero, setne, truev, falsev)

```
def SDT_RISCVSelectCC     : SDTypeProfile<1, 5, [SDTCisSameAs<1, 2>,
                                                 SDTCisSameAs<0, 4>,
                                                 SDTCisSameAs<4, 5>]>;

def riscv_selectcc  : SDNode<"TOYRISCVISD::SELECT_CC", SDT_RISCVSelectCC>;
def IntCCtoRISCVCC : SDNodeXForm<riscv_selectcc, [{
  ISD::CondCode CC = cast<CondCodeSDNode>(N->getOperand(2))->get();
  TOYRISCVCC::CondCode BrCC = getRISCVCCForIntCC(CC);
  return CurDAG->getTargetConstant(BrCC, SDLoc(N), Subtarget->getXLenVT());
}]>;

def riscv_selectcc_frag : PatFrag<(ops node:$lhs, node:$rhs, node:$cc,
                                       node:$truev, node:$falsev),
                                  (riscv_selectcc node:$lhs, node:$rhs,
                                                  node:$cc, node:$truev,
                                                  node:$falsev), [{}],
                                  IntCCtoRISCVCC>;

let usesCustomInserter = 1 in
class SelectCC_rrirr<RegisterClass valty, RegisterClass cmpty>
    : Pseudo<(outs valty:$dst),
             (ins cmpty:$lhs, cmpty:$rhs, ixlenimm:$imm,
              valty:$truev, valty:$falsev),
             [(set valty:$dst,
               (riscv_selectcc_frag:$imm cmpty:$lhs, cmpty:$rhs, cond,
                                         valty:$truev, valty:$falsev))]>;

def Select_GPR_Using_CC_GPR : SelectCC_rrirr<GPR, GPR>;

```
