/* My attempt at a custom pool allocator.
 *
 * My implementation of a pool allocator works like an Arena,
 * when a node is allocated, it simply grows its own arena index
 * and returns the newly grown area.
 * When a node is freed, it is added to a linked list
 * of free'd nodes, these nodes are stored in the same memory area;
 * overwriting old values with a pointer to the next free'd node.
 *
 * Since my pool allocator uses an index and a free'd node linked list,
 * it can be used as-is without any init procedure (in most cases).
 *
 * This implementation has a neat benefit of being capable
 * of being shared with other custom allocators, without
 * allocating nodes overwriting their data.
 * In this case, I've made it possible for this pool allocator
 * to lend away a single allocation.
 * This is taken advantage of by another custom allocator, an Arena.
 * The Arena is backing its memory off the Pool allocator, and
 * could grow its memory (as long as the Pool isn't growing its
 * Arena index).
 *
 * When said new Arena allocator free's its memory,
 * the Pool allocator has two options on how to free.
 * If the Pool allocator had to grow it's own Arena
 * (Like if the free-list wasn't empty),
 * then it cannot simply shrink its Arena, so it will
 * commit the Area's memory to the free list.
 * Otherwise it can simply shrink its Arena index
 * and forget about it.
 *
 * While my implemenation isn't perfect,
 * it allows for a Pool allocator to share its memory
 * with an Arena allocator.
 * As far as I see it, this could be used
 * with a linked-list Piece-Table.
 * */


package main


import "core:fmt"
import "core:mem"


main :: proc()
{
	using fmt

	/* My context custom allocator
	 * a mixture of an Arena and a pool allocator.
	 * */
	ctx := mem.Allocator{my_pool_allocator, nil}

	n1 := new(node, ctx); n1.data = 1
	n2 := new(node, ctx); n2.data = 2
	n3 := new(node, ctx); n3.data = 3
	n4 := new(node, ctx); n4.data = 4
	free(n1, ctx);
	free(n2, ctx);

	p2 := new(node, ctx); p2.data = 102;
	p1 := new(node, ctx); p1.data = 101;

	n5 := new(node, ctx); n5.data = 5

	/* Free everything by reseting Arena and free-list.
	 * This also preserves old data, allowing for the printing below.
	 * calling 'free' on the other pointers would not work,
	 * as node.data would be overwritten by free_node.next variable.
	 * */
	free_all(ctx)
	println("Node vals:", n1.data, n2.data, n3.data, n4.data, n5.data)


	for repeat in 0..<2 {
		println("-----------")

		tmp1 := new(node, ctx)
		tmp2 := new(node, ctx)
		free(tmp1, ctx)
		free(tmp2, ctx)

		ptr, len := pool_arena_grow(20)

		/* On the second iteration, we will force
		 * the Arena allocator to commit the Arena
		 * to the Pool allocator's free-list.
		 * */
		if repeat != 0 {
			println("[!] Forcing pool allocator to free arena to free-list.")
			pool_data.last = nil
		}
		pool_arena_free(transmute([^]u8)ptr, len)


		head : ^free_node = pool_data.next
		for head != nil {
			println("Free-List:", head, "->", head.next)
			head = head.next
		}

		for i in 0..<5 {
			forget := new(node, ctx)
			forget.data = 42
		}

		free_all(ctx)
	}
}

/* 'pool_arena_grow' and 'pool_arena_free' could
 * and should be contained in its own allocator.
 * But for the sake of readability (as this code
 * is meant to be easily understandable for others)
 * I've left them as their own two procedures.
 * Feel free to add them to an allocator structure tho.
 * */

pool_arena_grow :: proc(size : int) -> (ptr : rawptr, newsize : int)
{
	mod := size % size_of(node)
	if (mod > 0) {
		newsize = size + size_of(node) - mod
	} else {
		newsize = size
	}

	// Note: No bounds-checking, please do bound-checking.
	ptr = cast(rawptr)&pool_data.data[pool_data.index]
	pool_data.last = ptr
	pool_data.index += newsize

	fmt.println("Arena:\t", "Requested:", size,
		"bytes from pool, got", newsize, "bytes.")
	return // naked return, returns ptr & newsize
}

pool_arena_free :: proc(ptr : [^]u8, size : int)
{
	/* No new nodes grew the Arena,
	 * so it's safe to just shrink the Arena.
	 * */
	if (pool_data.last != nil) {
		pool_data.index = cast(int)(cast(uintptr)pool_data.last \
			- cast(uintptr)&pool_data.data[0])
		pool_data.last = nil
		fmt.println("Arena:\t", "Safely freed the Arena (shrunk Pool Arena index).")
	} else {
		/* Since new node allocations grew the arena,
		 * we cannot simply shrink the Arena without accidentally
		 * deleting / overwriting the new node(s).
		 * So we'll populate this Arena section with
		 * free-list nodes and attach them to the free-list.
		 * */
		prev, next : ^free_node = pool_data.next, ---
		counter : int
		for i := 0; i < size; i += size_of(node) {
			next = transmute(^free_node)(&ptr[i])

			next.next = prev
			prev = next
			counter += 1
		}

		pool_data.next = prev
		fmt.println("Arena:\t", "Freed Arena to pool Free-List, Nodes:", counter)
	}
}

my_pool_allocator :: proc(
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

	#partial switch mode {
	case .Alloc:
		ptr : []u8

		// Grow arena and return new area.
		if pool_data.next == nil && pool_data.index < size_of(pool_data.data) {
			ptr = pool_data.data[pool_data.index:][:size]
			pool_data.last = cast(rawptr)&ptr[0]
			pool_data.index += size
			println("Pool:\t Grew Arena to", pool_data.index)
			return ptr, .None
		}

		// Use linked list of free'd nodes.
		if pool_data.next != nil && pool_data.index < size_of(pool_data.data) {
			println("Pool:\t Popped node from free-list.")

			// First time I am learning about '[^]T'... Cool.
			// ptr = (cast([^]u8)pool_data.next)[:size]
			ptr = ([^]u8)(pool_data.next)[:size]
			pool_data.next = pool_data.next.next

			return ptr, .None
		}

	case .Free:
		// Push node to free list.
		println("Pool:\t Pushed free'd node into free-list.")

		head := cast(^free_node)old_memory
		head.next = pool_data.next
		pool_data.next = head

		return nil, .None

	case .Resize:
		/* New node allocations grew arena,
		 * or realloc call wasn't the lastest,
		 * or no Arena was never grown.
		 * Safely return old address and size.
		 * */
		if pool_data.last != old_memory || pool_data.last == nil {
			return ([^]u8)(old_memory)[:old_size], .None
		}

		// We can safely increase the last Arena allocation size.
		// TODO: Grow last Arena size.
	case .Free_All:
		pool_data.index = 0
		pool_data.last = nil
		pool_data.next = nil
		println("Pool & Arena: Reset/Freed Pool allocator.")

	case: // Default case.
		return nil, .Mode_Not_Implemented
	}

	return nil, .Out_Of_Memory
}


pool_data : struct {
	data  : [0x8000]u8 // 32kb backing buffer, replace with actual heap!
	index : int        // Index into buffer of memory used.

	// Terrible variable names, :(
	last : rawptr     // Last Arena growth.
	next : ^free_node // Free List.
}

// Packed for printing reasons, just in case.
node :: struct #packed {
	/* To preserve data on node free (use after free);
	 * uncomment variable below.
	 * This is because free_node.next is 4-8 bytes,
	 * and pushing node data after the pointer prevents
	 * data being overwritten.
	 *
	 * Consider writing code so that use after free
	 * does not happen, but in a minority of cases,
	 * it could be benefitial? I suppose?
	 * */
	// _preserve_on_free : ^free_node

	data : u8
	data2: [16 - 1]u8 // This node will take up 16 bytes.
}

free_node :: struct {
	next : ^free_node
}

/* If the linked free list node is larger than the nodes
 * with data, neighboring nodes would get overwritten on frees.
 * */
#assert(size_of(free_node) <= size_of(node))


/* Output:
Pool:    Grew Arena to 16
Pool:    Grew Arena to 32
Pool:    Grew Arena to 48
Pool:    Grew Arena to 64
Pool:    Pushed free'd node into free-list.
Pool:    Pushed free'd node into free-list.
Pool:    Popped node from free-list.
Pool:    Popped node from free-list.
Pool:    Grew Arena to 80
Pool & Arena: Reset/Freed Pool allocator.
Node vals: 101 102 3 4 5
-----------
Pool:    Grew Arena to 16
Pool:    Grew Arena to 32
Pool:    Pushed free'd node into free-list.
Pool:    Pushed free'd node into free-list.
Arena:   Requested: 20 bytes from pool, got 32 bytes.
Arena:   Safely freed the Arena (shrunk Pool Arena index).
Free-List: &free_node{next = 0xA} -> &free_node{next = <nil>}
Free-List: &free_node{next = <nil>} -> <nil>
Pool:    Popped node from free-list.
Pool:    Popped node from free-list.
Pool:    Grew Arena to 48
Pool:    Grew Arena to 64
Pool:    Grew Arena to 80
Pool & Arena: Reset/Freed Pool allocator.
-----------
Pool:    Grew Arena to 16
Pool:    Grew Arena to 32
Pool:    Pushed free'd node into free-list.
Pool:    Pushed free'd node into free-list.
Arena:   Requested: 20 bytes from pool, got 32 bytes.
[!] Forcing pool allocator to free arena to free-list.
Arena:   Freed Arena to pool Free-List, Nodes: 2
Free-List: &free_node{next = 0xC} -> &free_node{next = 0xB}
Free-List: &free_node{next = 0xB} -> &free_node{next = 0xA}
Free-List: &free_node{next = 0xA} -> &free_node{next = <nil>}
Free-List: &free_node{next = <nil>} -> <nil>
Pool:    Popped node from free-list.
Pool:    Popped node from free-list.
Pool:    Popped node from free-list.
Pool:    Popped node from free-list.
Pool:    Grew Arena to 80
Pool & Arena: Reset/Freed Pool allocator.
*/
