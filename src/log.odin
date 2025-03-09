package main

import "core:fmt"
import "core:os"
import "core:strings"
import sdl "vendor:sdl3"

// Prefixes will create prefix_log.txt files. Should always include the empty string "" for the standard log file.
init_logs :: proc(log_prefixes: ..string) {
	// Truncs all log files to be used. Basically, wipes all log files that have old stuff in them
	for prefix in log_prefixes {
		slice := [?]string { prefix, "log.txt" }
		file_name := strings.concatenate(slice[:])

		log_fd, open_error := os.open(file_name, os.O_RDWR | os.O_TRUNC | os.O_CREATE)
		os.close(log_fd)

		delete(file_name)
	}
}

// Function that will write data to a log file.
// prefix argument is for writing to specific log files, if so desired.
log :: proc(data: string, args: ..any, file_prefix : string = "", location := #caller_location) {
	// Can only concatenate string slices... so here we are
	slice := [?]string { file_prefix, "log.txt" }
	file_name := strings.concatenate(slice[:])

	log_fd, open_error := os.open(file_name, os.O_APPEND)
	for open_error != os.ERROR_NONE {
		fmt.eprintfln("Well this is awkward... opening log file %s failed. OS Error: %v", file_name, os.error_string(open_error))
		return
	}

	// Formatting the log write...
	log_builder := strings.builder_make()

	fmt.sbprintf(&log_builder, "%.2f @ %v.odin(%v) -> ", get_uptime(), location.procedure, location.line)
	fmt.sbprintf(&log_builder, data, ..args)
	strings.write_byte(&log_builder, '\n')
	
	// no i really dont know what the int does. it doesnt even have a variable name in the docs. its just: Int
	idk_what_this_int_does, write_error := os.write_string(log_fd, strings.to_string(log_builder))

	os.close(log_fd)

	strings.builder_destroy(&log_builder)

	if write_error != os.ERROR_NONE {
        fmt.eprintfln("Well this is awkward... writing to log file %s failed. OS Error: ", file_name, os.error_string(write_error))
    }

	delete(file_name)
}