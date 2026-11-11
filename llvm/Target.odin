/*===-- llvm-c/Target.h - Target Lib C Iface --------------------*- C++ -*-===*/
/*                                                                            */
/* Part of the LLVM Project, under the Apache License v2.0 with LLVM          */
/* Exceptions.                                                                */
/* See https://llvm.org/LICENSE.txt for license information.                  */
/* SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception                    */
/*                                                                            */
/*===----------------------------------------------------------------------===*/
/*                                                                            */
/* This header declares the C interface to libLLVMTarget.a, which             */
/* implements target information.                                             */
/*                                                                            */
/* Many exotic languages can interoperate with C code but have a harder time  */
/* with C++ due to name mangling. So in addition to C, this interface enables */
/* tools written in such languages.                                           */
/*                                                                            */
/*===----------------------------------------------------------------------===*/
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
* @defgroup LLVMCTarget Target information
* @ingroup LLVMC
*
* @{
*/
ByteOrdering :: enum u32 {
	/**
	* @defgroup LLVMCTarget Target information
	* @ingroup LLVMC
	*
	* @{
	*/
	BigEndian    = 0,

	/**
	* @defgroup LLVMCTarget Target information
	* @ingroup LLVMC
	*
	* @{
	*/
	LittleEndian = 1,
}

TargetDataRef                :: ^OpaqueTargetData
OpaqueTargetData             :: struct {}
TargetLibraryInfoRef         :: ^OpaqueTargetLibraryInfotData
OpaqueTargetLibraryInfotData :: struct {}

@(default_calling_convention="c", link_prefix="LLVM")
foreign lib {
	/**
	* Obtain the data layout for a module.
	*
	* @see Module::getDataLayout()
	*/
	GetModuleDataLayout :: proc(M: ModuleRef) -> TargetDataRef ---

	/**
	* Set the data layout for a module.
	*
	* @see Module::setDataLayout()
	*/
	SetModuleDataLayout :: proc(M: ModuleRef, DL: TargetDataRef) ---

	/** Creates target data from a target layout string.
	See the constructor llvm::DataLayout::DataLayout. */
	CreateTargetData :: proc(StringRep: cstring) -> TargetDataRef ---

	/** Deallocates a TargetData.
	See the destructor llvm::DataLayout::~DataLayout. */
	DisposeTargetData :: proc(TD: TargetDataRef) ---

	/** Adds target library information to a pass manager. This does not take
	ownership of the target library info.
	See the method llvm::PassManagerBase::add. */
	AddTargetLibraryInfo :: proc(TLI: TargetLibraryInfoRef, PM: PassManagerRef) ---

	/** Converts target data to a target layout string. The string must be disposed
	with LLVMDisposeMessage.
	See the constructor llvm::DataLayout::DataLayout. */
	CopyStringRepOfTargetData :: proc(TD: TargetDataRef) -> cstring ---

	/** Returns the byte order of a target, either LLVMBigEndian or
	LLVMLittleEndian.
	See the method llvm::DataLayout::isLittleEndian. */
	ByteOrder :: proc(TD: TargetDataRef) -> ByteOrdering ---

	/** Returns the pointer size in bytes for a target.
	See the method llvm::DataLayout::getPointerSize. */
	PointerSize :: proc(TD: TargetDataRef) -> u32 ---

	/** Returns the pointer size in bytes for a target for a specified
	address space.
	See the method llvm::DataLayout::getPointerSize. */
	PointerSizeForAS :: proc(TD: TargetDataRef, AS: u32) -> u32 ---

	/** Returns the integer type that is the same size as a pointer on a target.
	See the method llvm::DataLayout::getIntPtrType. */
	IntPtrType :: proc(TD: TargetDataRef) -> TypeRef ---

	/** Returns the integer type that is the same size as a pointer on a target.
	This version allows the address space to be specified.
	See the method llvm::DataLayout::getIntPtrType. */
	IntPtrTypeForAS :: proc(TD: TargetDataRef, AS: u32) -> TypeRef ---

	/** Returns the integer type that is the same size as a pointer on a target.
	See the method llvm::DataLayout::getIntPtrType. */
	IntPtrTypeInContext :: proc(C: ContextRef, TD: TargetDataRef) -> TypeRef ---

	/** Returns the integer type that is the same size as a pointer on a target.
	This version allows the address space to be specified.
	See the method llvm::DataLayout::getIntPtrType. */
	IntPtrTypeForASInContext :: proc(C: ContextRef, TD: TargetDataRef, AS: u32) -> TypeRef ---

	/** Computes the size of a type in bits for a target.
	See the method llvm::DataLayout::getTypeSizeInBits. */
	SizeOfTypeInBits :: proc(TD: TargetDataRef, Ty: TypeRef) -> u64 ---

	/** Computes the storage size of a type in bytes for a target.
	See the method llvm::DataLayout::getTypeStoreSize. */
	StoreSizeOfType :: proc(TD: TargetDataRef, Ty: TypeRef) -> u64 ---

	/** Computes the ABI size of a type in bytes for a target.
	See the method llvm::DataLayout::getTypeAllocSize. */
	ABISizeOfType :: proc(TD: TargetDataRef, Ty: TypeRef) -> u64 ---

	/** Computes the ABI alignment of a type in bytes for a target.
	See the method llvm::DataLayout::getTypeABISize. */
	ABIAlignmentOfType :: proc(TD: TargetDataRef, Ty: TypeRef) -> u32 ---

	/** Computes the call frame alignment of a type in bytes for a target.
	See the method llvm::DataLayout::getTypeABISize. */
	CallFrameAlignmentOfType :: proc(TD: TargetDataRef, Ty: TypeRef) -> u32 ---

	/** Computes the preferred alignment of a type in bytes for a target.
	See the method llvm::DataLayout::getTypeABISize. */
	PreferredAlignmentOfType :: proc(TD: TargetDataRef, Ty: TypeRef) -> u32 ---

	/** Computes the preferred alignment of a global variable in bytes for a target.
	See the method llvm::DataLayout::getPreferredAlignment. */
	PreferredAlignmentOfGlobal :: proc(TD: TargetDataRef, GlobalVar: ValueRef) -> u32 ---

	/** Computes the structure element that contains the byte offset for a target.
	See the method llvm::StructLayout::getElementContainingOffset. */
	ElementAtOffset :: proc(TD: TargetDataRef, StructTy: TypeRef, Offset: u64) -> u32 ---

	/** Computes the byte offset of the indexed struct element for a target.
	See the method llvm::StructLayout::getElementContainingOffset. */
	OffsetOfElement :: proc(TD: TargetDataRef, StructTy: TypeRef, Element: u32) -> u64 ---
}

/*

Generated by odin_llvm

Mimic what is done in 'Target.h'.
The generated 'Initialize*' functions are based on
what 'llvm-config --targets-built' returns.

*/

@(default_calling_convention="c", link_prefix="LLVM")
foreign lib {
	InitializeAArch64TargetInfo :: proc() ---
	InitializeAArch64Target :: proc() ---
	InitializeAArch64TargetMC :: proc() ---
	InitializeAArch64AsmPrinter :: proc() ---
	InitializeAArch64AsmParser :: proc() ---
	InitializeAArch64Disassembler :: proc() ---
	InitializeAMDGPUTargetInfo :: proc() ---
	InitializeAMDGPUTarget :: proc() ---
	InitializeAMDGPUTargetMC :: proc() ---
	InitializeAMDGPUAsmPrinter :: proc() ---
	InitializeAMDGPUAsmParser :: proc() ---
	InitializeAMDGPUDisassembler :: proc() ---
	InitializeARMTargetInfo :: proc() ---
	InitializeARMTarget :: proc() ---
	InitializeARMTargetMC :: proc() ---
	InitializeARMAsmPrinter :: proc() ---
	InitializeARMAsmParser :: proc() ---
	InitializeARMDisassembler :: proc() ---
	InitializeAVRTargetInfo :: proc() ---
	InitializeAVRTarget :: proc() ---
	InitializeAVRTargetMC :: proc() ---
	InitializeAVRAsmPrinter :: proc() ---
	InitializeAVRAsmParser :: proc() ---
	InitializeAVRDisassembler :: proc() ---
	InitializeBPFTargetInfo :: proc() ---
	InitializeBPFTarget :: proc() ---
	InitializeBPFTargetMC :: proc() ---
	InitializeBPFAsmPrinter :: proc() ---
	InitializeBPFAsmParser :: proc() ---
	InitializeBPFDisassembler :: proc() ---
	InitializeHexagonTargetInfo :: proc() ---
	InitializeHexagonTarget :: proc() ---
	InitializeHexagonTargetMC :: proc() ---
	InitializeHexagonAsmPrinter :: proc() ---
	InitializeHexagonAsmParser :: proc() ---
	InitializeHexagonDisassembler :: proc() ---
	InitializeLanaiTargetInfo :: proc() ---
	InitializeLanaiTarget :: proc() ---
	InitializeLanaiTargetMC :: proc() ---
	InitializeLanaiAsmPrinter :: proc() ---
	InitializeLanaiAsmParser :: proc() ---
	InitializeLanaiDisassembler :: proc() ---
	InitializeLoongArchTargetInfo :: proc() ---
	InitializeLoongArchTarget :: proc() ---
	InitializeLoongArchTargetMC :: proc() ---
	InitializeLoongArchAsmPrinter :: proc() ---
	InitializeLoongArchAsmParser :: proc() ---
	InitializeLoongArchDisassembler :: proc() ---
	InitializeMipsTargetInfo :: proc() ---
	InitializeMipsTarget :: proc() ---
	InitializeMipsTargetMC :: proc() ---
	InitializeMipsAsmPrinter :: proc() ---
	InitializeMipsAsmParser :: proc() ---
	InitializeMipsDisassembler :: proc() ---
	InitializeMSP430TargetInfo :: proc() ---
	InitializeMSP430Target :: proc() ---
	InitializeMSP430TargetMC :: proc() ---
	InitializeMSP430AsmPrinter :: proc() ---
	InitializeMSP430AsmParser :: proc() ---
	InitializeMSP430Disassembler :: proc() ---
	InitializeNVPTXTargetInfo :: proc() ---
	InitializeNVPTXTarget :: proc() ---
	InitializeNVPTXTargetMC :: proc() ---
	InitializeNVPTXAsmPrinter :: proc() ---
	InitializeNVPTXAsmParser :: proc() ---
	InitializeNVPTXDisassembler :: proc() ---
	InitializePowerPCTargetInfo :: proc() ---
	InitializePowerPCTarget :: proc() ---
	InitializePowerPCTargetMC :: proc() ---
	InitializePowerPCAsmPrinter :: proc() ---
	InitializePowerPCAsmParser :: proc() ---
	InitializePowerPCDisassembler :: proc() ---
	InitializeRISCVTargetInfo :: proc() ---
	InitializeRISCVTarget :: proc() ---
	InitializeRISCVTargetMC :: proc() ---
	InitializeRISCVAsmPrinter :: proc() ---
	InitializeRISCVAsmParser :: proc() ---
	InitializeRISCVDisassembler :: proc() ---
	InitializeSparcTargetInfo :: proc() ---
	InitializeSparcTarget :: proc() ---
	InitializeSparcTargetMC :: proc() ---
	InitializeSparcAsmPrinter :: proc() ---
	InitializeSparcAsmParser :: proc() ---
	InitializeSparcDisassembler :: proc() ---
	InitializeSPIRVTargetInfo :: proc() ---
	InitializeSPIRVTarget :: proc() ---
	InitializeSPIRVTargetMC :: proc() ---
	InitializeSPIRVAsmPrinter :: proc() ---
	InitializeSPIRVAsmParser :: proc() ---
	InitializeSPIRVDisassembler :: proc() ---
	InitializeSystemZTargetInfo :: proc() ---
	InitializeSystemZTarget :: proc() ---
	InitializeSystemZTargetMC :: proc() ---
	InitializeSystemZAsmPrinter :: proc() ---
	InitializeSystemZAsmParser :: proc() ---
	InitializeSystemZDisassembler :: proc() ---
	InitializeVETargetInfo :: proc() ---
	InitializeVETarget :: proc() ---
	InitializeVETargetMC :: proc() ---
	InitializeVEAsmPrinter :: proc() ---
	InitializeVEAsmParser :: proc() ---
	InitializeVEDisassembler :: proc() ---
	InitializeWebAssemblyTargetInfo :: proc() ---
	InitializeWebAssemblyTarget :: proc() ---
	InitializeWebAssemblyTargetMC :: proc() ---
	InitializeWebAssemblyAsmPrinter :: proc() ---
	InitializeWebAssemblyAsmParser :: proc() ---
	InitializeWebAssemblyDisassembler :: proc() ---
	InitializeX86TargetInfo :: proc() ---
	InitializeX86Target :: proc() ---
	InitializeX86TargetMC :: proc() ---
	InitializeX86AsmPrinter :: proc() ---
	InitializeX86AsmParser :: proc() ---
	InitializeX86Disassembler :: proc() ---
	InitializeXCoreTargetInfo :: proc() ---
	InitializeXCoreTarget :: proc() ---
	InitializeXCoreTargetMC :: proc() ---
	InitializeXCoreAsmPrinter :: proc() ---
	InitializeXCoreAsmParser :: proc() ---
	InitializeXCoreDisassembler :: proc() ---
}

InitializeAllTargetInfos :: proc() {
	InitializeAArch64TargetInfo()
	InitializeAMDGPUTargetInfo()
	InitializeARMTargetInfo()
	InitializeAVRTargetInfo()
	InitializeBPFTargetInfo()
	InitializeHexagonTargetInfo()
	InitializeLanaiTargetInfo()
	InitializeLoongArchTargetInfo()
	InitializeMipsTargetInfo()
	InitializeMSP430TargetInfo()
	InitializeNVPTXTargetInfo()
	InitializePowerPCTargetInfo()
	InitializeRISCVTargetInfo()
	InitializeSparcTargetInfo()
	InitializeSPIRVTargetInfo()
	InitializeSystemZTargetInfo()
	InitializeVETargetInfo()
	InitializeWebAssemblyTargetInfo()
	InitializeX86TargetInfo()
	InitializeXCoreTargetInfo()
}

InitializeAllTargets :: proc() {
	InitializeAArch64Target()
	InitializeAMDGPUTarget()
	InitializeARMTarget()
	InitializeAVRTarget()
	InitializeBPFTarget()
	InitializeHexagonTarget()
	InitializeLanaiTarget()
	InitializeLoongArchTarget()
	InitializeMipsTarget()
	InitializeMSP430Target()
	InitializeNVPTXTarget()
	InitializePowerPCTarget()
	InitializeRISCVTarget()
	InitializeSparcTarget()
	InitializeSPIRVTarget()
	InitializeSystemZTarget()
	InitializeVETarget()
	InitializeWebAssemblyTarget()
	InitializeX86Target()
	InitializeXCoreTarget()
}

InitializeAllTargetMCs :: proc() {
	InitializeAArch64TargetMC()
	InitializeAMDGPUTargetMC()
	InitializeARMTargetMC()
	InitializeAVRTargetMC()
	InitializeBPFTargetMC()
	InitializeHexagonTargetMC()
	InitializeLanaiTargetMC()
	InitializeLoongArchTargetMC()
	InitializeMipsTargetMC()
	InitializeMSP430TargetMC()
	InitializeNVPTXTargetMC()
	InitializePowerPCTargetMC()
	InitializeRISCVTargetMC()
	InitializeSparcTargetMC()
	InitializeSPIRVTargetMC()
	InitializeSystemZTargetMC()
	InitializeVETargetMC()
	InitializeWebAssemblyTargetMC()
	InitializeX86TargetMC()
	InitializeXCoreTargetMC()
}

InitializeAllAsmPrinters :: proc() {
	InitializeAArch64AsmPrinter()
	InitializeAMDGPUAsmPrinter()
	InitializeARMAsmPrinter()
	InitializeAVRAsmPrinter()
	InitializeBPFAsmPrinter()
	InitializeHexagonAsmPrinter()
	InitializeLanaiAsmPrinter()
	InitializeLoongArchAsmPrinter()
	InitializeMipsAsmPrinter()
	InitializeMSP430AsmPrinter()
	InitializeNVPTXAsmPrinter()
	InitializePowerPCAsmPrinter()
	InitializeRISCVAsmPrinter()
	InitializeSparcAsmPrinter()
	InitializeSPIRVAsmPrinter()
	InitializeSystemZAsmPrinter()
	InitializeVEAsmPrinter()
	InitializeWebAssemblyAsmPrinter()
	InitializeX86AsmPrinter()
	InitializeXCoreAsmPrinter()
}

InitializeAllAsmParsers :: proc() {
	InitializeAArch64AsmParser()
	InitializeAMDGPUAsmParser()
	InitializeARMAsmParser()
	InitializeAVRAsmParser()
	InitializeBPFAsmParser()
	InitializeHexagonAsmParser()
	InitializeLanaiAsmParser()
	InitializeLoongArchAsmParser()
	InitializeMipsAsmParser()
	InitializeMSP430AsmParser()
	InitializeNVPTXAsmParser()
	InitializePowerPCAsmParser()
	InitializeRISCVAsmParser()
	InitializeSparcAsmParser()
	InitializeSPIRVAsmParser()
	InitializeSystemZAsmParser()
	InitializeVEAsmParser()
	InitializeWebAssemblyAsmParser()
	InitializeX86AsmParser()
	InitializeXCoreAsmParser()
}

InitializeAllDisassemblers :: proc() {
	InitializeAArch64Disassembler()
	InitializeAMDGPUDisassembler()
	InitializeARMDisassembler()
	InitializeAVRDisassembler()
	InitializeBPFDisassembler()
	InitializeHexagonDisassembler()
	InitializeLanaiDisassembler()
	InitializeLoongArchDisassembler()
	InitializeMipsDisassembler()
	InitializeMSP430Disassembler()
	InitializeNVPTXDisassembler()
	InitializePowerPCDisassembler()
	InitializeRISCVDisassembler()
	InitializeSparcDisassembler()
	InitializeSPIRVDisassembler()
	InitializeSystemZDisassembler()
	InitializeVEDisassembler()
	InitializeWebAssemblyDisassembler()
	InitializeX86Disassembler()
	InitializeXCoreDisassembler()
}

/*

End of what was generated by odin_llvm

*/
