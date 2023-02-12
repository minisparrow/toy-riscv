cd /path/to/toy-riscv-backend
./setup.bash
cd ./llvm-project/
mkdir -p ./build && cd ./build
cmake -G Ninja -DCMAKE_BUILD_TYPE=Debug -DLLVM_TARGETS_TO_BUILD="X86;TOYRISCV;RISCV" -DLLVM_ENABLE_PROJECTS="clang;libcxx;libcxxabi" ../llvm
ninja
