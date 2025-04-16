package g4n

import sdl "vendor:sdl3"

import "core:log"
import "core:fmt"
import "core:c/libc"
import "core:mem"

@(require_results)
create_tracking_allocator :: proc() -> (t_alloc: mem.Tracking_Allocator) {
	default_allocator := context.allocator
	mem.tracking_allocator_init(&t_alloc, default_allocator)

	return
}

report_tracking_allocator :: proc(t_alloc: ^mem.Tracking_Allocator) {
	err := false

	if len(t_alloc.allocation_map) > 0 {
		log.logf(.Info, "\n\n\n== MEMORY LEAKS ==")
	} else {
		log.logf(.Debug, "No memory leaks =)")
	}

	for _, value in t_alloc.allocation_map {
		fmt.printfln("%v: Leaked %v bytes", value.location, value.size)
		log.logf(.Warning, "%v: Leaked %v bytes", value.location, value.size)
		err = true
	}

	mem.tracking_allocator_clear(t_alloc)
	if err { libc.getchar() }
}

destroy_tracking_allocator :: proc(t_alloc: ^mem.Tracking_Allocator) {
	mem.tracking_allocator_destroy(t_alloc)
}

check_tracking_allocator :: proc(t_alloc: ^mem.Tracking_Allocator) {
	if len(t_alloc.bad_free_array) > 0 {
		for b in t_alloc.bad_free_array {
			log.logf(.Error, "Bad free at: %v", b.location)
		}
	
		libc.getchar()
		panic("Bad free detected!")
	}
}
