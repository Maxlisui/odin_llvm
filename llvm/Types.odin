/*===-- llvm-c/Support.h - C Interface Types declarations ---------*- C -*-===*\
|*                                                                            *|
|* Part of the LLVM Project, under the Apache License v2.0 with LLVM          *|
|* Exceptions.                                                                *|
|* See https://llvm.org/LICENSE.txt for license information.                  *|
|* SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception                    *|
|*                                                                            *|
|*===----------------------------------------------------------------------===*|
|*                                                                            *|
|* This file defines types used by the C interface to LLVM.                   *|
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
* @defgroup LLVMCSupportTypes Types and Enumerations
*
* @{
*/
Bool :: b32

/**
* Used to pass regions of memory through LLVM interfaces.
*
* @see llvm::MemoryBuffer
*/
MemoryBufferRef    :: ^OpaqueMemoryBuffer
OpaqueMemoryBuffer :: struct {}

/**
* The top-level container for all LLVM global data. See the LLVMContext class.
*/
ContextRef    :: ^OpaqueContext
OpaqueContext :: struct {}
OpaqueModule  :: struct {}

/**
* The top-level container for all other LLVM Intermediate Representation (IR)
* objects.
*
* @see llvm::Module
*/
ModuleRef  :: ^OpaqueModule
OpaqueType :: struct {}

/**
* Each value in the LLVM IR has a type, an LLVMTypeRef.
*
* @see llvm::Type
*/
TypeRef     :: ^OpaqueType
OpaqueValue :: struct {}

/**
* Represents an individual value in LLVM IR.
*
* This models llvm::Value.
*/
ValueRef         :: ^OpaqueValue
OpaqueBasicBlock :: struct {}

/**
* Represents a basic block of instructions in LLVM IR.
*
* This models llvm::BasicBlock.
*/
BasicBlockRef  :: ^OpaqueBasicBlock
OpaqueMetadata :: struct {}

/**
* Represents an LLVM Metadata.
*
* This models llvm::Metadata.
*/
MetadataRef       :: ^OpaqueMetadata
OpaqueNamedMDNode :: struct {}

/**
* Represents an LLVM Named Metadata Node.
*
* This models llvm::NamedMDNode.
*/
NamedMDNodeRef           :: ^OpaqueNamedMDNode
OpaqueValueMetadataEntry :: struct {}

/**
* Represents an entry in a Global Object's metadata attachments.
*
* This models std::pair<unsigned, MDNode *>
*/
ValueMetadataEntry :: OpaqueValueMetadataEntry

/**
* Represents an LLVM basic block builder.
*
* This models llvm::IRBuilder.
*/
BuilderRef      :: ^OpaqueBuilder
OpaqueBuilder   :: struct {}
OpaqueDIBuilder :: struct {}

/**
* Represents an LLVM debug info builder.
*
* This models llvm::DIBuilder.
*/
DIBuilderRef         :: ^OpaqueDIBuilder
OpaqueModuleProvider :: struct {}

/**
* Interface used to provide a module to JIT or interpreter.
* This is now just a synonym for llvm::Module, but we have to keep using the
* different type to keep binary compatibility.
*/
ModuleProviderRef :: ^OpaqueModuleProvider
OpaquePassManager :: struct {}

/** @see llvm::PassManagerBase */
PassManagerRef :: ^OpaquePassManager
OpaqueUse      :: struct {}

/**
* Used to get the users and usees of a Value.
*
* @see llvm::Use */
UseRef :: ^OpaqueUse

/**
* @see llvm::OperandBundleDef
*/
OperandBundleRef    :: ^OpaqueOperandBundle
OpaqueOperandBundle :: struct {}
OpaqueAttributeRef  :: struct {}

/**
* Used to represent an attributes.
*
* @see llvm::Attribute
*/
AttributeRef :: ^OpaqueAttributeRef

/**
* @see llvm::DiagnosticInfo
*/
DiagnosticInfoRef    :: ^OpaqueDiagnosticInfo
OpaqueDiagnosticInfo :: struct {}

/**
* @see llvm::Comdat
*/
ComdatRef             :: ^Comdat
Comdat                :: struct {}
OpaqueModuleFlagEntry :: struct {}

/**
* @see llvm::Module::ModuleFlagEntry
*/
ModuleFlagEntry        :: OpaqueModuleFlagEntry
OpaqueJITEventListener :: struct {}

/**
* @see llvm::JITEventListener
*/
JITEventListenerRef :: ^OpaqueJITEventListener
OpaqueBinary        :: struct {}

/**
* @see llvm::object::Binary
*/
BinaryRef       :: ^OpaqueBinary
OpaqueDbgRecord :: struct {}

/**
* @see llvm::DbgRecord
*/
DbgRecordRef :: ^OpaqueDbgRecord

