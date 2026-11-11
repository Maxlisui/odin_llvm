/*===-- llvm-c/Support.h - Support C Interface --------------------*- C -*-===*\
|*                                                                            *|
|* Part of the LLVM Project, under the Apache License v2.0 with LLVM          *|
|* Exceptions.                                                                *|
|* See https://llvm.org/LICENSE.txt for license information.                  *|
|* SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception                    *|
|*                                                                            *|
|*===----------------------------------------------------------------------===*|
|*                                                                            *|
|* This file defines the C interface to the LLVM support library.             *|
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
	* This function permanently loads the dynamic library at the given path.
	* It is safe to call this function multiple times for the same library.
	*
	* @see sys::DynamicLibrary::LoadLibraryPermanently()
	*/
	LoadLibraryPermanently :: proc(Filename: cstring) -> Bool ---

	/**
	* This function parses the given arguments using the LLVM command line parser.
	* Note that the only stable thing about this function is its signature; you
	* cannot rely on any particular set of command line arguments being interpreted
	* the same way across LLVM versions.
	*
	* @see llvm::cl::ParseCommandLineOptions()
	*/
	ParseCommandLineOptions :: proc(argc: i32, argv: ^cstring, Overview: cstring) ---

	/**
	* This function will search through all previously loaded dynamic
	* libraries for the symbol \p symbolName. If it is found, the address of
	* that symbol is returned. If not, null is returned.
	*
	* @see sys::DynamicLibrary::SearchForAddressOfSymbol()
	*/
	SearchForAddressOfSymbol :: proc(symbolName: cstring) -> rawptr ---

	/**
	* This functions permanently adds the symbol \p symbolName with the
	* value \p symbolValue.  These symbols are searched before any
	* libraries.
	*
	* @see sys::DynamicLibrary::AddSymbol()
	*/
	AddSymbol :: proc(symbolName: cstring, symbolValue: rawptr) ---
}

