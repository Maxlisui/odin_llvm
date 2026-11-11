# Odin LLVM

Odin bindings and a bindings generator for the LLVM-C API.

## Bindings

The generated bindings reside in the [llvm](llvm) folder.
Clone or download the repository and copy the folder into your project.
It is highly recommended you generate the bindings specifically
for your LLVM installation. See [A note on Targets](#a-note-on-targets).

### Config flags

The generated bindings provide two `#config` flags in [llvm_config.odin](llvm/llvm_config.odin).

- `LLVM_USE_SYSTEM_LIBS`: Defaults to `true` and decides whether `system:LLVM` is used
or `llvm/lib/LLVM-C.lib` (Windows), `llvm/lib/libLLVM.so` (Linux)
and `llvm/lib/libLLVM.dylib` (macOS).
- `LLVM_USE_PREFER_LOCAL_LIBS`: Defaults to `true` and only valid if
`LLVM_USE_SYSTEM_LIBS` is `true`.
If set, prefer the libraries in `llvm/lib/` over `system:LLVM`.

### A note on Targets

The committed bindings are generated under x86_64 Linux,
with all supported LLVM targets built.

<details>
<summary>List of targets</summary>

```sh
$ llvm-config --targets-built
AArch64 AMDGPU ARM AVR BPF Hexagon Lanai LoongArch Mips MSP430 NVPTX PowerPC RISCV Sparc SPIRV SystemZ VE WebAssembly X86 XCore
```

</details>

Calling any of the `LLVMInitialize*` functions for targets that are not
included in your installation will result in linker errors.
The bindings also include the `LLVMInitializeAll*` set of functions.
When calling them, ensure your installation includes all targets.

To get bindings that fit your installation and requirements,
it is generally recommended that you generate the bindings yourself.

### Version History

- [23.1.5](https://github.com/Maxlisui/odin_llvm/tree/23.1.5)
- [22.1.8](https://github.com/Maxlisui/odin_llvm/tree/22.1.8)

## Generator

The generator is based on the work of
[odin-c-bindgen](https://github.com/karl-zylinski/odin-c-bindgen)
by Karl Zylinski et al.
The actual [generator used](https://github.com/Maxlisui/odin-c-bindgen/tree/non-styem-wide-libclang)
is a fork that streamlines `libclang` handling.
Since an LLVM installation usually includes it, the wrapper can try to
automatically detect and find the needed `libclang` library.

### Requirements

- [Odin](https://odin-lang.org/)
- An LLVM installation
- `libclang` (either provided by the LLVM installation or installed globally)

### Usage

```sh
# Unix
odin build . -out:llvm_gen.bin
./llvm_gen.bin <path/to/llvm-config>

# Windows
odin build . -out:llvm_gen.exe
./llvm_gen.exe <path\to\llvm-config.exe>
```

## License

- This repository is distributed under the MIT License. See [`LICENSE`](LICENSE) for details.
- [odin-c-bindgen](odin-c-bindgen) is distributed under the zlib License.
- LLVM is distributed under the Apache License v2.0 with LLVM Exceptions.
