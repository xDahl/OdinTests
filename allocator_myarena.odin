/* This code is hot garbage, just some experimental
 * attempts at understanding Odin's custom allocators.
 *
 * As my first attempt, I wrote a (wrong and bad) Arena allocator.
 * Its cons are:
 * 	1) Doesn't check if its out of memory.
 * 	2) Doesn't do any boundary checking on its memory.
 * 	3) Doesn't initialize memory to 0.
 * 	4) Only uses a small amount global stack memory.
 * Its pros are:
 * 	1) Does allow you to free its last allocation (once).
 * 	2) Can free all memory efficiently.
 * */

package main


import "core:fmt"
import "core:mem"


print_darray :: proc(s : string, a : [dynamic]int)
{
	fmt.println(s)
	for i := 0; i < len(a); i += 1 {
		fmt.printf("Array[%d] = %d\n", i, a[i])
	}
}


main :: proc()
{
	using fmt

	/* Create a variable named 'c',
	 * that is a type of mem.Allocator struct,
	 * with a procedure pointer to my allocator procedure.
	 * Procedure data is nil. */
	c : mem.Allocator = {procedure = my_allocator, data = nil}


	print_arena()


	// Small allocation test, limited scope.
	{
		arr := make([dynamic]int, 3, 4, c)
		defer delete(arr) // Freed at end of scope

		// Fill up the length.
		for i := 0; i < 3; i += 1 {
			arr[i] = i
		}
		print_darray("Filled up length of array", arr);

		append(&arr, 3)
		print_darray("Filled up capacity of array", arr);

		append(&arr, 4)
		print_darray("Resized & appended past old capacity", arr);
	}


	print_arena()


	// Allocate memory of different sizes.
	{
		ia : ^i32 = new(i32, c)
		ib := new(i64, c)

		ic := new(i8, c)
		free(ic, c)

		id := new(i16, c)

		ia^ = 0x32323232
		ib^ = 0x6464646464646464
		id^ = 0x1616

		// free(ia, c) // Will fail.
		// free(id, c) // Will succeed.

		/* Will fail even if above free is commented out,
		 * as my arena allocator can only free the most
		 * recent allocation, nothing before. */
		// free(ib, c)

		// Can free all memory efficiently.
		free_all(c)
	}


	print_arena()


	{
		LEN :: 26
		arr := new([LEN]u16, c)
		defer free(arr, c)

		for i := 0; i < LEN; i += 1 {
			arr[i] = 'a' + cast(u16)i
		}
	}


	print_arena()
}

my_allocator :: proc(
	allocator_data : rawptr,
	mode : mem.Allocator_Mode,
	size : int,
	alignment : int,
	old_memory : rawptr,
	old_size : int,
	location := #caller_location
	) -> ([]u8, mem.Allocator_Error)
{
	using fmt

	// println("Called my allocator :D")

	println("Allocation information:",
		"\n\tRequest:", mode,
		"\n\tSize:", size,
		"\n\tOld size:", old_size)

	if old_memory != nil {
		println("\tAt arena index:",
			cast(uintptr)&my_arena.data[0] - cast(uintptr)old_memory)
	} else {
		println("\tAt arena index: NA")
	}


	#partial switch mode {
	case .Alloc:
		println("\tLast:", my_arena.last, "Index:", my_arena.index)

		my_arena.last = my_arena.index
		my_arena.index += size

		/* I find this syntax weird in Odin, but it means:
		 * slice[offset : offset + length] */
		return my_arena.data[my_arena.last:][:size], .None

	case .Resize:
		// My arena can only resize the last allocation.
		if old_memory != &my_arena.data[my_arena.last] {
			return nil, .Invalid_Argument
		}

		my_arena.index = my_arena.last + size
		return my_arena.data[my_arena.last : size], .None

	case .Free:
		if old_memory != &my_arena.data[my_arena.last] {
			return nil, .Invalid_Argument
		}

		my_arena.index = my_arena.last
		return nil, .None

	case .Free_All:
		my_arena.index = 0
		my_arena.last = 0

	case: /* Default case. */
		return nil, .Mode_Not_Implemented
	}

	return nil, .Out_Of_Memory
}

/* I'll be using this small amount of global memory for testing.
 * If you need actual memory on heap, I think you use 'mem.alloc_bytes()'?
 * This is just for testing anyway,
 * and getting used to Odin's custom allocators. */
my_arena : struct {
	data : [512]u8
	index, last : int
} = {data = {0..<512=0xFF}} // To make demonstrations easier to understand.

print_arena :: proc()
{
	using fmt

	println("\n\nCurrent Areana data:")
	for i := 0; i < min(len(my_arena.data), 0x40); i += 1 {
		if i % 8 == 0 {
			printf("%s%4X:  ",
				i == 0 ? "" : "\n",
				i)
		}
		printf("%2X ", my_arena.data[i])
	}
	println("\n\n")
}

/* Output:
Current Areana data:
0000:  FF FF FF FF FF FF FF FF
0008:  FF FF FF FF FF FF FF FF
0010:  FF FF FF FF FF FF FF FF
0018:  FF FF FF FF FF FF FF FF
0020:  FF FF FF FF FF FF FF FF
0028:  FF FF FF FF FF FF FF FF
0030:  FF FF FF FF FF FF FF FF
0038:  FF FF FF FF FF FF FF FF


Allocation information:
        Request: Alloc
        Size: 32
        Old size: 0
        At arena index: NA
        Last: 0 Index: 0
Filled up length of array
Array[0] = 0
Array[1] = 1
Array[2] = 2
Filled up capacity of array
Array[0] = 0
Array[1] = 1
Array[2] = 2
Array[3] = 3
Allocation information:
        Request: Resize
        Size: 128
        Old size: 32
        At arena index: 0
Resized & appended past old capacity
Array[0] = 0
Array[1] = 1
Array[2] = 2
Array[3] = 3
Array[4] = 4
Allocation information:
        Request: Free
        Size: 0
        Old size: 128
        At arena index: 0


Current Areana data:
0000:  00 00 00 00 00 00 00 00
0008:  01 00 00 00 00 00 00 00
0010:  02 00 00 00 00 00 00 00
0018:  03 00 00 00 00 00 00 00
0020:  04 00 00 00 00 00 00 00
0028:  FF FF FF FF FF FF FF FF
0030:  FF FF FF FF FF FF FF FF
0038:  FF FF FF FF FF FF FF FF


Allocation information:
        Request: Alloc
        Size: 4
        Old size: 0
        At arena index: NA
        Last: 0 Index: 0
Allocation information:
        Request: Alloc
        Size: 8
        Old size: 0
        At arena index: NA
        Last: 0 Index: 4
Allocation information:
        Request: Alloc
        Size: 1
        Old size: 0
        At arena index: NA
        Last: 4 Index: 12
Allocation information:
        Request: Free
        Size: 0
        Old size: 0
        At arena index: ---
Allocation information:
        Request: Alloc
        Size: 2
        Old size: 0
        At arena index: NA
        Last: 12 Index: 12
Allocation information:
        Request: Free_All
        Size: 0
        Old size: 0
        At arena index: NA


Current Areana data:
0000:  32 32 32 32 64 64 64 64
0008:  64 64 64 64 16 16 00 00
0010:  02 00 00 00 00 00 00 00
0018:  03 00 00 00 00 00 00 00
0020:  04 00 00 00 00 00 00 00
0028:  FF FF FF FF FF FF FF FF
0030:  FF FF FF FF FF FF FF FF
0038:  FF FF FF FF FF FF FF FF


Allocation information:
        Request: Alloc
        Size: 52
        Old size: 0
        At arena index: NA
        Last: 0 Index: 0
Allocation information:
        Request: Free
        Size: 0
        Old size: 0
        At arena index: 0


Current Areana data:
0000:  61 00 62 00 63 00 64 00
0008:  65 00 66 00 67 00 68 00
0010:  69 00 6A 00 6B 00 6C 00
0018:  6D 00 6E 00 6F 00 70 00
0020:  71 00 72 00 73 00 74 00
0028:  75 00 76 00 77 00 78 00
0030:  79 00 7A 00 FF FF FF FF
0038:  FF FF FF FF FF FF FF FF
*/
