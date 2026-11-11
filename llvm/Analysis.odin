/*===-- llvm-c/Analysis.h - Analysis Library C Interface --------*- C++ -*-===*\
|*                                                                            *|
|* Part of the LLVM Project, under the Apache License v2.0 with LLVM          *|
|* Exceptions.                                                                *|
|* See https://llvm.org/LICENSE.txt for license information.                  *|
|* SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception                    *|
|*                                                                            *|
|*===----------------------------------------------------------------------===*|
|*                                                                            *|
|* This header declares the C interface to libLLVMAnalysis.a, which           *|
|* implements various analyses of the LLVM IR.                                *|
|*                                                                            *|
|* Many exotic languages can interoperate with C code but have a harder time  *|
|* with C++ due to name mangling. So in addition to C, this interface enables *|
|* tools written in such languages.                                           *|
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


/**
* @defgroup LLVMCAnalysis Analysis
* @ingroup LLVMC
*
* @{
*/
VerifierFailureAction :: enum u32 {
	AbortProcessAction = 0, /* verifier will print to stderr and abort() */
	PrintMessageAction = 1, /* verifier will print to stderr and return 1 */
	ReturnStatusAction = 2, /* verifier will just return 1 */
}

@(default_calling_convention="c", link_prefix="LLVM")
foreign lib {
	/* Verifies that a module is valid, taking the specified action if not.
	Optionally returns a human-readable description of any invalid constructs.
	OutMessage must be disposed with LLVMDisposeMessage. */
	VerifyModule :: proc(M: ModuleRef, Action: VerifierFailureAction, OutMessage: ^cstring) -> Bool ---

	/* Verifies that a single function is valid, taking the specified action. Useful
	for debugging. */
	VerifyFunction :: proc(Fn: ValueRef, Action: VerifierFailureAction) -> Bool ---

	/* Open up a ghostview window that displays the CFG of the current function.
	Useful for debugging. */
	ViewFunctionCFG     :: proc(Fn: ValueRef) ---
	ViewFunctionCFGOnly :: proc(Fn: ValueRef) ---
}

