/*===-- llvm-c/Disassembler.h - Disassembler Public C Interface ---*- C -*-===*\
|*                                                                            *|
|* Part of the LLVM Project, under the Apache License v2.0 with LLVM          *|
|* Exceptions.                                                                *|
|* See https://llvm.org/LICENSE.txt for license information.                  *|
|* SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception                    *|
|*                                                                            *|
|*===----------------------------------------------------------------------===*|
|*                                                                            *|
|* This header provides a public interface to a disassembler library.         *|
|* LLVM provides an implementation of this interface.                         *|
|*                                                                            *|
\*===----------------------------------------------------------------------===*/
package llvm

when ODIN_OS == .Windows {
  when LLVM_USE_SYSTEM_LIBS {
    when LLVM_USE_PREFER_LOCAL_LIBS && #exists("./lib/LLVM-C.lib") {
      foreign import lib "./lib/LLVM-C.lib"
    } else {
      foreign import lib "system:LLVM-C.lib"
    }
  } else {
    when !#exists("./lib/LLVM-C.lib") {
      #panic("LLVM_USE_SYSTEM_LIBS is false but lib/LLVM-C.lib does not exist!")
    }
    foreign import lib "./lib/LLVM-C.lib"
  }
} else when ODIN_OS == .Linux {
  when LLVM_USE_SYSTEM_LIBS {
    when LLVM_USE_PREFER_LOCAL_LIBS && #exists("./lib/libLLVM.so") {
      foreign import lib "./lib/libLLVM.so"
    } else {
      foreign import lib "system:LLVM"
    }
  } else {
    when !#exists("./lib/libLLVM.so") {
      #panic("LLVM_USE_SYSTEM_LIBS is false but lib/libLLVM.so does not exist!")
    }
    foreign import lib "./lib/libLLVM.so"
  }
} else when ODIN_OS == .Darwin {
  when LLVM_USE_SYSTEM_LIBS {
    when LLVM_USE_PREFER_LOCAL_LIBS && #exists("./lib/libLLVM.dylib") {
      foreign import lib "./lib/libLLVM.dylib"
    } else {
      foreign import lib "system:LLVM"
    }
  } else {
    when !#exists("./lib/libLLVM.dylib") {
      #panic("LLVM_USE_SYSTEM_LIBS is false but lib/libLLVM.dylib does not exist!")
    }
    foreign import lib "./lib/libLLVM.dylib"
  }
} else {
  #panic("Unsupported target platform")
}


DisassemblerOptionKind :: enum int {
	/* The option to produce marked up assembly. */
	UseMarkup         = 0,

	/* The option to print immediates as hex. */
	PrintImmHex       = 1,

	/* The option use the other assembler printer variant */
	AsmPrinterVariant = 2,

	/* The option to set comment on instructions */
	SetInstrComments  = 3,

	/* The option to print latency information alongside instructions */
	PrintLatency      = 4,

	/* The option to print in color */
	Color             = 5,
}

DisassemblerOption :: bit_set[DisassemblerOptionKind; int]

@(default_calling_convention="c", link_prefix="LLVM")
foreign lib {
	/**
	* Create a disassembler for the TripleName.  Symbolic disassembly is supported
	* by passing a block of information in the DisInfo parameter and specifying the
	* TagType and callback functions as described above.  These can all be passed
	* as NULL.  If successful, this returns a disassembler context.  If not, it
	* returns NULL. This function is equivalent to calling
	* LLVMCreateDisasmCPUFeatures() with an empty CPU name and feature set.
	*/
	CreateDisasm :: proc(TripleName: cstring, DisInfo: rawptr, TagType: i32, GetOpInfo: OpInfoCallback, SymbolLookUp: SymbolLookupCallback) -> DisasmContextRef ---

	/**
	* Create a disassembler for the TripleName and a specific CPU.  Symbolic
	* disassembly is supported by passing a block of information in the DisInfo
	* parameter and specifying the TagType and callback functions as described
	* above.  These can all be passed * as NULL.  If successful, this returns a
	* disassembler context.  If not, it returns NULL. This function is equivalent
	* to calling LLVMCreateDisasmCPUFeatures() with an empty feature set.
	*/
	CreateDisasmCPU :: proc(Triple: cstring, CPU: cstring, DisInfo: rawptr, TagType: i32, GetOpInfo: OpInfoCallback, SymbolLookUp: SymbolLookupCallback) -> DisasmContextRef ---

	/**
	* Create a disassembler for the TripleName, a specific CPU and specific feature
	* string.  Symbolic disassembly is supported by passing a block of information
	* in the DisInfo parameter and specifying the TagType and callback functions as
	* described above.  These can all be passed * as NULL.  If successful, this
	* returns a disassembler context.  If not, it returns NULL.
	*/
	CreateDisasmCPUFeatures :: proc(Triple: cstring, CPU: cstring, Features: cstring, DisInfo: rawptr, TagType: i32, GetOpInfo: OpInfoCallback, SymbolLookUp: SymbolLookupCallback) -> DisasmContextRef ---

	/**
	* Set the disassembler's options.  Returns 1 if it can set the Options and 0
	* otherwise.
	*/
	SetDisasmOptions :: proc(DC: DisasmContextRef, Options: u64) -> i32 ---

	/**
	* Dispose of a disassembler context.
	*/
	DisasmDispose :: proc(DC: DisasmContextRef) ---

	/**
	* Disassemble a single instruction using the disassembler context specified in
	* the parameter DC.  The bytes of the instruction are specified in the
	* parameter Bytes, and contains at least BytesSize number of bytes.  The
	* instruction is at the address specified by the PC parameter.  If a valid
	* instruction can be disassembled, its string is returned indirectly in
	* OutString whose size is specified in the parameter OutStringSize.  This
	* function returns the number of bytes in the instruction or zero if there was
	* no valid instruction.
	*/
	DisasmInstruction :: proc(DC: DisasmContextRef, Bytes: ^u8, BytesSize: u64, PC: u64, OutString: cstring, OutStringSize: i32) -> i32 ---
}

