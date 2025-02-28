This is a continuation of riscv-32 port.

## TODOs:
Fix incorrect relocation for LA ✅

Add basic operaction for long long

Add load/store calling/returing for long long

Fix incorrect relocation when initialing array with anonymous struct which contains a pointer to a global symbol

## Quick start

Currently, the work is focused on building a cross compiler with `build=host=x86_64-linux` and `target=riscv32i_Zicsr-ilp32-linux`.

A `riscv32-ilp32` toolschain is required. Since the pre-build toolschains provided by the RISC-V Collaboration for `riscv32` are for `ilp32d`, you will need to clone the [toolschain repo](https://github.com/riscv-collab/riscv-gnu-toolchain) and
build it manually.

```sh
# Inside toolschain repository
./configure --prefix=/opt/riscv32-gnu-toolchain-glibc-sf --with-arch=rv32g --with-abi=ilp32 # or with-arch=rv32i_Zicsr
sudo make linux
```

Please notice that this repository hard-codes the toolschain path in the test routines (tests/tests2/Makefile). If you wish to
change the prefix, you will need to modify the Makefile mentioned above.

To build the cross compiler, create a file named `config-extra.mak` with the following contents:
```make
ROOT-riscv32-ilp32 = /opt/riscv32-gnu-toolchain-glibc-sf/sysroot/
CRT-riscv32-ilp32 = {R}/usr/lib
LIB-riscv32-ilp32 = {B}:{R}/lib:{R}/usr/lib
INC-riscv32-ilp32  = {B}/include:{R}/include:{R}/usr/include:{R}/../lib/gcc/riscv32-unknown-linux-gnu/14.2.0/include
# you might want to change the 14.2.0 according to your toolschain

```
Then run the following command:
```sh
# Inside this repository
./configure --enable-cross --debug --cpu=riscv32
make riscv32-ilp32-tcc
```

To run the built-in tests, run the follw command:
```sh
cp riscv32-ilp32-tcc tcc
make tests2.all
```

## Known bug

I also collect some programs that current version of tcc-rv32 failed to compile
as follow

```c
struct Wrap {
  int *digit;
};
int aaa;
struct Wrap global_wrap[] = {
 ((struct Wrap) {&aaa}),
};
int main() {}
```
Result: `tcc: error: undefined symbol ''`

```c
//compile only
struct x { int a, b, c; }; // must contains at lease 3 elements

void b (struct x);

void foo(){
  struct x aa = {1,1,1};

  b (aa);
}
```
Result: tcc crashed, segmentation fault. At tccgen.c:type_size
