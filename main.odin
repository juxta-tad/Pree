package main

import "core:fmt"
import "pree"

main :: proc() {
	pree.start()

	pree.printf(.debug,"hey im in the main proc \nsecond line \n3rd line")
	pree.printf(.error,"hey im in the main proc \nsecond line \n3rd line")
	baz()
	foooioota()
}

foooioota :: proc() {
	pree.start()
	pree.printf(.debug,"who came up with this name???")
}

baz :: proc() {
	pree.start()
	pree.printf(.warning,"sometimes i cant sleep at night")

	foooioota()
}

