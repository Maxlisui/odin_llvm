/*===-- llvm-c/IRReader.h - IR Reader C Interface -----------------*- C -*-===*\
|*                                                                            *|
|* Part of the LLVM Project, under the Apache License v2.0 with LLVM          *|
|* Exceptions.                                                                *|
|* See https://llvm.org/LICENSE.txt for license information.                  *|
|* SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception                    *|
|*                                                                            *|
|*===----------------------------------------------------------------------===*|
|*                                                                            *|
|* This file defines the C interface to the IR Reader.                        *|
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


@(default_calling_convention="c", link_prefix="LLVM")
foreign lib {
	/**
	* Read LLVM IR from a memory buffer and convert it into an in-memory Module
	* object. Returns 0 on success.
	* Optionally returns a human-readable description of any errors that
	* occurred during parsing IR. OutMessage must be disposed with
	* LLVMDisposeMessage.
	* The memory buffer is consumed by this function.
	* This is deprecated. Use LLVMParseIRInContext2 instead.
	*
	* @see llvm::ParseIR()
	*/
	ParseIRInContext :: proc(ContextRef: ContextRef, MemBuf: MemoryBufferRef, OutM: ^ModuleRef, OutMessage: ^cstring) -> Bool ---

	/**
	* Read LLVM IR from a memory buffer and convert it into an in-memory Module
	* object. Returns 0 on success.
	* Optionally returns a human-readable description of any errors that
	* occurred during parsing IR. OutMessage must be disposed with
	* LLVMDisposeMessage.
	* The memory buffer is not consumed by this function. It is the responsibility
	* of the caller to free it with \c LLVMDisposeMemoryBuffer.
	*
	* @see llvm::ParseIR()
	*/
	ParseIRInContext2 :: proc(ContextRef: ContextRef, MemBuf: MemoryBufferRef, OutM: ^ModuleRef, OutMessage: ^cstring) -> Bool ---
}

