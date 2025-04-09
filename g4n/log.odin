package g4n
import sdl "vendor:sdl3"
import "core:fmt"
import "core:os"
import "core:strings"


// Prefixes will create prefix_log.txt files. Should always include the empty string "" for the standard log file.
init_logs :: proc(log_prefixes: ..string) {
	// Truncs all log files to be used. Basically, wipes all log files that have old stuff in them
	for prefix in log_prefixes {
		slice := [?]string { prefix, "log.txt" }
		fileName := strings.concatenate(slice[:])

		logFileDescript, openErr := os.open(fileName, os.O_RDWR | os.O_TRUNC | os.O_CREATE)
		os.close(logFileDescript)

		delete(fileName)
	}
}

// Function that will write data to a log file.
// prefix argument is for writing to specific log files, if so desired.
log :: proc(data: string, args: ..any, file_prefix : string = "", location := #caller_location) {
	// Can only concatenate string slices... so here we are
	slice := [?]string { file_prefix, "log.txt" }
	fileName := strings.concatenate(slice[:])

	logFileDescript, openErr := os.open(fileName, os.O_APPEND)
	for openErr != os.ERROR_NONE {
		fmt.eprintfln("Well this is awkward... opening log file %s failed. OS Error: %v", fileName, os.error_string(openErr))
		return
	}

	// Formatting the log write...
	logBuilder := strings.builder_make()

	fmt.sbprintf(&logBuilder, "%.2f @ %v.odin(%v) -> ", get_uptime(), location.procedure, location.line)
	fmt.sbprintf(&logBuilder, data, ..args)
	strings.write_byte(&logBuilder, '\n')
	
	// no i really dont know what the int does. it doesnt even have a variable name in the docs. its just: Int
	idk_what_this_int_does, writeErr := os.write_string(logFileDescript, strings.to_string(logBuilder))

	os.close(logFileDescript)

	strings.builder_destroy(&logBuilder)

	if writeErr != os.ERROR_NONE {
        fmt.eprintfln("Well this is awkward... writing to log file %s failed. OS Error: ", fileName, os.error_string(writeErr))
    }

	delete(fileName)
}