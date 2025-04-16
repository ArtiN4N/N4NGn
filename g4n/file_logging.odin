package g4n

import "core:log"
import "core:os"

create_file_logger :: proc(path: string, level: log.Level) -> log.Logger {
    log_handle, err := os.open(path, os.O_WRONLY | os.O_APPEND | os.O_CREATE | os.O_TRUNC, 0o644)
	if err != os.ERROR_NONE {
		panic("Can't craete the log file!")
	}
	return log.create_file_logger(log_handle, level)
}

destroy_file_logger :: proc(logger: log.Logger) {
    // This proc closes the file handle itself! yay!
	log.destroy_file_logger(logger)
}