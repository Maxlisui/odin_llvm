package main

import "core:fmt"
import "core:log"
import "core:mem"
import "core:mem/virtual"
import "core:os"
import "core:path/filepath"
import "core:strings"

My_Error :: enum {
	None,
	Command,
	LLVM,
	Generator_Setup,
	Lib_Clang,
}

Error :: union #shared_nil {
	os.Error,
	mem.Allocator_Error,
	My_Error,
}

run_command :: proc(
	args: []string,
	log_error := true,
	allocator := context.allocator,
) -> (
	stdout: string,
	err: Error,
) {
	log.debugf("Running command: %v", args)

	desc: os.Process_Desc
	desc.command = args

	stdout_bytes: []byte
	stderr_bytes: []byte
	state: os.Process_State
	state, stdout_bytes, stderr_bytes, err = os.process_exec(desc, allocator)
	defer delete(stderr_bytes, allocator)
	defer if err != nil {
		delete(stdout_bytes, allocator)
	}

	stdout = strings.trim_space(transmute(string)stdout_bytes)
	stderr := strings.trim_space(transmute(string)stderr_bytes)

	if err != nil {
		if log_error {
			log.errorf("Command %v failed with error %v", args, err)

			if len(stdout) > 0 {
				log.errorf("Command %v stdout:\n%s", args, stdout)
			}

			if len(stderr) > 0 {
				log.errorf("Command %v stderr:\n%s", args, stderr)
			}
		}
	} else if state.exit_code != 0 {
		err = .Command

		if log_error {
			log.errorf("Command %v returned non 0 exit code", args)

			if len(stdout) > 0 {
				log.errorf("Command %v stdout:\n%s", args, stdout)
			}

			if len(stderr) > 0 {
				log.errorf("Command %v stderr:\n%s", args, stderr)
			}
		}
	}

	return
}

llvm_config_path: string
llvm_version: string
llvm_include_dir: string
llvm_include_dir_llvm_c: string
llvm_lib_dir: string
llvm_bin_dir: string
llvm_targets: []string

prepare_llvm :: proc() -> (err: Error) {
	llvm_version = run_command({llvm_config_path, "--version"}) or_return
	llvm_include_dir = run_command({llvm_config_path, "--includedir"}) or_return
	llvm_lib_dir = run_command({llvm_config_path, "--libdir"}) or_return
	llvm_bin_dir = run_command({llvm_config_path, "--bindir"}) or_return
	llvm_targets_string := run_command({llvm_config_path, "--targets-built"}) or_return

	llvm_targets = strings.split(llvm_targets_string, " ") or_return
	for &t in llvm_targets {
		t = strings.trim_space(t)
	}

	log.infof("LLVM config: %s", llvm_config_path)
	log.infof("LLVM version: %s", llvm_version)
	log.infof("LLVM include dir: %s", llvm_include_dir)
	log.infof("LLVM library dir: %s", llvm_lib_dir)
	log.infof("LLVM binary dir: %s", llvm_bin_dir)
	log.infof("LLVM targets: %v", llvm_targets)

	if !os.exists(llvm_include_dir) {
		log.errorf("LLVM include directory does not exist, was: '%s'", llvm_include_dir)
		err = .LLVM
	}

	if !os.exists(llvm_lib_dir) {
		log.errorf("LLVM library directory does not exist, was: '%s'", llvm_lib_dir)
		err = .LLVM
	}

	if !os.exists(llvm_bin_dir) {
		log.errorf("LLVM binary directory does not exist, was: '%s'", llvm_bin_dir)
		err = .LLVM
	}

	llvm_include_dir_llvm_c = filepath.join({llvm_include_dir, "llvm-c"}) or_return
	if !os.exists(llvm_include_dir_llvm_c) {
		log.errorf("LLVM-C include directory does not exist, was: '%s'", llvm_include_dir_llvm_c)
		err = .LLVM
	}

	return
}

when ODIN_OS == .Windows {
	LIBCLANG :: "libclang.lib"
	LIBCLANG_DLL :: "libclang.dll"
} else when ODIN_OS == .Linux {
	LIBCLANG :: "libclang.so"
} else {
	#panic("OS not supported")
}

GENERATOR_DIR :: "odin-c-bindgen"

when ODIN_OS == .Windows {
	GENERATOR_EXE :: "bindgen.exe"
} else when ODIN_OS == .Linux || ODIN_OS == .Darwin {
	GENERATOR_EXE :: "bindgen.bin"
} else {
	#panic("OS not supported")
}

GENERATOR_BUILD_OUT :: "-out:" + GENERATOR_EXE

generator_src: string
generator_lib_clang: string

has_lib_clang :: proc() -> (has: bool) {
	when ODIN_OS == .Windows {
		log.infof("Looking for libclang in '%s' and " + LIBCLANG_DLL + ".", generator_lib_clang)
	} else {
		log.infof("Looking for libclang in '%s'.", generator_lib_clang)
	}

	if os.exists(generator_lib_clang) {
		when ODIN_OS == .Windows {
			if os.exists(LIBCLANG_DLL) {
				has = true
			}
		} else {
			has = true
		}
	}
	return
}

find_libclang :: proc() -> Error {
	when ODIN_OS == .Windows {
		return find_libclang_win32()
	} else when ODIN_OS == .Linux {
		return find_libclang_linux()
	} else {
		#panic("OS not supported")
	}
}

when ODIN_OS == .Windows {
	find_libclang_win32 :: proc() -> (err: Error) {
		expected_libclang := filepath.join({llvm_lib_dir, LIBCLANG}, context.temp_allocator) or_return
		defer delete(expected_libclang)

		log.infof("Looking for libclang.lib in '%s'.", expected_libclang)

		if os.exists(expected_libclang) {
			expected_libclang_dll := filepath.join({llvm_bin_dir, LIBCLANG_DLL}, context.temp_allocator) or_return
			defer delete(expected_libclang_dll)

			log.infof("Looking for libclang.dll in '%s'.", expected_libclang_dll)

			if os.exists(expected_libclang_dll) {
				log.info("Found libclang.lib and libclang.dll, copying to the generator.")

				os.copy_file(generator_lib_clang, expected_libclang) or_return
				os.copy_file(LIBCLANG_DLL, expected_libclang_dll) or_return
			} else {
				log.errorf(
					"Could not find libclang.dll in '%s'. Copy it manually to the root directory.",
					expected_libclang_dll,
				)
				err = .Lib_Clang
			}
		} else {
			log.errorf(
				"Could not find libclang.lib in '%s'. Copy it manually to '%s'.",
				expected_libclang,
				generator_lib_clang,
			)
			err = .Lib_Clang
		}

		return
	}
} else when ODIN_OS == .Linux {
	find_libclang_linux :: proc() -> (err: Error) {
		expected_libclang := filepath.join({llvm_lib_dir, LIBCLANG}, context.temp_allocator) or_return
		defer delete(expected_libclang)

		log.infof("Looking for libclang.so in '%s'.", expected_libclang)

		if os.exists(expected_libclang) {
			log.info("Found libclang.so, copying to the generator.")

			os.copy_file(generator_lib_clang, expected_libclang) or_return
		} else {
			log.errorf(
				"Could not find libclang.so in '%s'. Copy it manually to '%s' or install libclang.",
				expected_libclang,
				generator_lib_clang,
			)
			err = .Lib_Clang
		}
		return
	}
}

build_generator :: proc() -> (err: Error) {
	cmd_with_libclang := [?]string {
		"odin",
		"build",
		generator_src,
		GENERATOR_BUILD_OUT,
		"-define:LIBCLANG_USE_SYSTEM_LIB=false",
	}
	cmd_without_libclang := [?]string{"odin", "build", generator_src, GENERATOR_BUILD_OUT}

	if has_lib_clang() {
		log.info(LIBCLANG + " exists in the generator directory, trying to compile.")
		run_command(cmd_with_libclang[:]) or_return
	} else {
		log.info(LIBCLANG + " does not exist trying to compile with system libclang.")
		_, err = run_command(cmd_without_libclang[:], false)
		if err != nil {
			err = nil

			log.info("Compiling with system libclang failed, trying to find " + LIBCLANG + ".")
			find_libclang() or_return

			if os.exists(generator_lib_clang) {
				log.info(LIBCLANG + " should be ready now, compiling the generator.")
				run_command(cmd_with_libclang[:]) or_return
			} else {
				log.errorf("We found libclang but there is still no libclang in '%s'.", generator_lib_clang)
				err = .Lib_Clang
			}
		}
	}

	return
}

prepare_generator :: proc() -> (err: Error) {
	generator_readme := filepath.join({GENERATOR_DIR, "README.md"}, context.temp_allocator) or_return
	defer delete(generator_readme, context.temp_allocator)

	if !os.exists(generator_readme) {
		log.info("Generator README does not exist, trying a `git submodule update`.")
		run_command({"git", "submodule", "update", "--init", "--recursive"}) or_return
	}

	if os.exists(generator_readme) {
		generator_src = filepath.join({GENERATOR_DIR, "src"}) or_return
		generator_lib_clang = filepath.join({GENERATOR_DIR, "libclang", LIBCLANG}) or_return

		build_generator() or_return
	} else {
		err = .Generator_Setup
		log.errorf(
			"Expected the generator readme to exist in '%s'. Tried a `git submodule update` but file does still not exist.",
			generator_readme,
		)
	}

	return
}

prepare_bindgen_file :: proc() -> (err: Error) {
	bindgen_file := filepath.join({"resources", "bindgen.sjson"}, context.temp_allocator) or_return
	defer delete(bindgen_file, context.temp_allocator)

	bindgen_content := transmute(string)os.read_entire_file_from_path(bindgen_file, context.temp_allocator) or_return
	defer delete(bindgen_content, context.temp_allocator)

	include_dir := llvm_include_dir
	when ODIN_OS == .Windows {
		include_dir = filepath.replace_separators(include_dir, '/') or_return
	}

	patched_bindgen_content, was_allocation := strings.replace_all(
		bindgen_content,
		"{LLVM_INCLUDE_DIR}",
		include_dir,
		context.temp_allocator,
	)
	defer if was_allocation {
		delete(patched_bindgen_content, context.temp_allocator)
	}

	os.write_entire_file_from_string("bindgen.sjson", patched_bindgen_content) or_return

	return
}

TARGET_FOOTER_HEADER :: `/*

Generated by odin_llvm

Mimic what is done in 'Target.h'.
The generated 'Initialize*' functions are based on
what 'llvm-config --targets-built' returns.

*/

@(default_calling_convention="c", link_prefix="LLVM")
foreign lib {
`

TARGET_FOOTER_FOOTER :: `/*

End of what was generated by odin_llvm

*/
`

prepare_target_footer :: proc() -> (err: Error) {
	builder: strings.Builder
	strings.builder_init(&builder)
	defer strings.builder_destroy(&builder)

	COMPONENTS :: []string{"TargetInfo", "Target", "TargetMC", "AsmPrinter", "AsmParser", "Disassembler"}

	strings.write_string(&builder, TARGET_FOOTER_HEADER)

	for t in llvm_targets {
		for c in COMPONENTS {
			fmt.sbprintfln(&builder, "\tInitialize%s%s :: proc() ---", t, c)
		}
	}

	strings.write_string(&builder, "}\n\n")

	for c in COMPONENTS {
		fmt.sbprintfln(&builder, "InitializeAll%ss :: proc() {{", c)

		for t in llvm_targets {
			fmt.sbprintfln(&builder, "\tInitialize%s%s()", t, c)
		}

		strings.write_string(&builder, "}\n\n")
	}

	strings.write_string(&builder, TARGET_FOOTER_FOOTER)


	footer_file := filepath.join({"llvm-c", "Target_footer.odin"}, context.temp_allocator) or_return
	defer delete(footer_file, context.temp_allocator)

	os.write_entire_file_from_string(footer_file, strings.to_string(builder)) or_return

	return
}

generate_bindings :: proc() -> (err: Error) {
	{
		log.infof("Copying '%s' to the root dir.", llvm_include_dir_llvm_c)
		os.copy_directory_all("llvm-c", llvm_include_dir_llvm_c) or_return
	}

	{
		log.info("Preparing 'bindgen.sjson'.")
		prepare_bindgen_file() or_return
	}

	{
		log.info("Preparing 'Target_footer.odin'.")
		prepare_target_footer() or_return
	}

	{
		log.info("Generating bindings.")
		run_command({GENERATOR_EXE, "."}) or_return
	}

	{
		config_file_src := filepath.join({"resources", "llvm_config.odin"}, context.temp_allocator) or_return
		config_file_dst := filepath.join({"llvm", "llvm_config.odin"}, context.temp_allocator) or_return
		defer delete(config_file_src, context.temp_allocator)
		defer delete(config_file_dst, context.temp_allocator)

		log.infof("Copy '%s' to '%s'.", config_file_src, config_file_dst)
		os.copy_file(config_file_dst, config_file_src) or_return
	}

	return
}

my_main :: proc() -> (exit_code: int, err: Error) {
	console_logger := log.create_console_logger()
	defer log.destroy_console_logger(console_logger)
	context.logger = console_logger

	arena: virtual.Arena
	virtual.arena_init_growing(&arena) or_return
	defer virtual.arena_destroy(&arena)
	context.allocator = virtual.arena_allocator(&arena)

	args := os.args
	exe := args[0]

	help_wanted := false
	{
		if len(args) > 1 {
			arg := args[1]

			if arg == "--help" || arg == "-h" {
				help_wanted = true
			} else {
				llvm_config_path = arg
			}
		} else {
			help_wanted = true
		}
	}

	if help_wanted {
		fmt.printfln("Usage: %s <llvm-config>", exe)
	} else {
		assert(len(llvm_config_path) > 0)

		prepare_llvm() or_return
		prepare_generator() or_return
		generate_bindings() or_return

		log.info("Bindings generation finished, validating bindings!")

		run_command({"odin", "check", "llvm", "-no-entry-point"}) or_return

		log.info("Bindings seem valid, `odin check` passes!")
	}

	return
}

main :: proc() {
	exit_code, err := my_main()
	if err != nil {
		switch v in err {
		case os.Error: fmt.eprintfln("Failed with OS error: %v", err)
		case mem.Allocator_Error: fmt.eprintfln("Failed with allocation error: %v", err)
		case My_Error: // Already printed
		}
		exit_code = 1
	}
	os.exit(exit_code)
}
