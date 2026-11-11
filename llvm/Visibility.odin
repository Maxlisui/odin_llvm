/*===-- llvm-c/Visibility.h - Visibility macros for llvm-c ------*- C++ -*-===*\
|*                                                                            *|
|* Part of the LLVM Project, under the Apache License v2.0 with LLVM          *|
|* Exceptions.                                                                *|
|* See https://llvm.org/LICENSE.txt for license information.                  *|
|* SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception                    *|
|*                                                                            *|
|*===----------------------------------------------------------------------===*|
|*                                                                            *|
|* This header defines visibility macros used for the LLVM C interface. These *|
|* macros are used to annotate C functions that should be exported as part of *|
|* a shared library or DLL.                                                   *|
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


