/*===-- llvm-c/Comdat.h - Module Comdat C Interface -------------*- C++ -*-===*\
|*                                                                            *|
|* Part of the LLVM Project, under the Apache License v2.0 with LLVM          *|
|* Exceptions.                                                                *|
|* See https://llvm.org/LICENSE.txt for license information.                  *|
|* SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception                    *|
|*                                                                            *|
|*===----------------------------------------------------------------------===*|
|*                                                                            *|
|* This file defines the C interface to COMDAT.                               *|
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
* @defgroup LLVMCCoreComdat Comdats
* @ingroup LLVMCCore
*
* @{
*/
ComdatSelectionKind :: enum u32 {
	AnyComdatSelectionKind           = 0, ///< The linker may choose any COMDAT.
	ExactMatchComdatSelectionKind    = 1, ///< The data referenced by the COMDAT must

	///< be the same.
	LargestComdatSelectionKind       = 2, ///< The linker will choose the largest

	///< COMDAT.
	NoDeduplicateComdatSelectionKind = 3, ///< No deduplication is performed.
	SameSizeComdatSelectionKind      = 4, ///< The data referenced by the COMDAT must be
}

@(default_calling_convention="c", link_prefix="LLVM")
foreign lib {
	/**
	* Return the Comdat in the module with the specified name. It is created
	* if it didn't already exist.
	*
	* @see llvm::Module::getOrInsertComdat()
	*/
	GetOrInsertComdat :: proc(M: ModuleRef, Name: cstring) -> ComdatRef ---

	/**
	* Get the Comdat assigned to the given global object.
	*
	* @see llvm::GlobalObject::getComdat()
	*/
	GetComdat :: proc(V: ValueRef) -> ComdatRef ---

	/**
	* Assign the Comdat to the given global object.
	*
	* @see llvm::GlobalObject::setComdat()
	*/
	SetComdat :: proc(V: ValueRef, C: ComdatRef) ---

	/*
	* Get the conflict resolution selection kind for the Comdat.
	*
	* @see llvm::Comdat::getSelectionKind()
	*/
	GetComdatSelectionKind :: proc(C: ComdatRef) -> ComdatSelectionKind ---

	/*
	* Set the conflict resolution selection kind for the Comdat.
	*
	* @see llvm::Comdat::setSelectionKind()
	*/
	SetComdatSelectionKind :: proc(C: ComdatRef, Kind: ComdatSelectionKind) ---
}

