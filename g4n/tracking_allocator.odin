package g4n
import sdl "vendor:sdl3"
import olog "core:log"
import "core:fmt"
import "core:c/libc"
import "core:mem"


create_tracking_allocator :: proc() -> mem.Tracking_Allocator {
	context.logger = olog.create_console_logger()

	default_allocator := context.allocator
	tracking_allocator: mem.Tracking_Allocator
	mem.tracking_allocator_init(&tracking_allocator, default_allocator)

	return tracking_allocator
}

destroy_tracking_allocator :: proc(t_alloc: ^mem.Tracking_Allocator) {
	err := false

	for _, value in t_alloc.allocation_map {
		log("%v: Leaked %v bytes", value.location, value.size)
		fmt.printfln("%v: Leaked %v bytes", value.location, value.size)
		err = true
	}

	mem.tracking_allocator_clear(t_alloc)
	if err { libc.getchar() }
	mem.tracking_allocator_destroy(t_alloc)
}

check_tracking_allocator :: proc(t_alloc: ^mem.Tracking_Allocator) {
	if len(t_alloc.bad_free_array) > 0 {
		for b in t_alloc.bad_free_array {
			log("Bad free at: %v", b.location)
			fmt.printfln("Bad free at: %v", b.location)
		}
	
		libc.getchar()
		panic("Bad free detected")
	}
}
