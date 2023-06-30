package main

import "core:fmt"

iter1 :: proc(index : int, n : []int) -> (int, bool)
{
	if index < len(n) {
		if n[index] & 1 != 1 {
			return n[index], true
		}
	}

	return 0, false
}

iter2 :: proc(index : int, n : []int) -> (int, int, bool)
{
	if index < len(n) {
		if n[index] & 1 != 1 {
			return n[index], index, true
		}
	}

	return 0, index, false
}

iter_struct :: struct {
	data  : []int,
	index : int
}

iter3 :: proc(is : ^iter_struct) -> (value, index : int, ok : bool) {
	if is.index < len(is.data) {
		if is.data[is.index] & 1 != 1 {
			value = is.data[is.index]
			index = is.index
			is.index += 1
			ok = true
			return
		}
	}
	return
}

main :: proc()
{
	// For this test, I'll be using custom iterators
	// to go through an array of numbers as long as they're even.
	// Custom iterators allows you to easily iterate over
	// different data structures (linked lists for instance),
	// and even skip specific elements.
	// The last return value in a custom iterator is what
	// determines if the loop continues.
	// Enums can be used as well afaik.
	array := [?]int{2, 4, 6, 8, 9, 10}


	// NOTE: Iterated values are copies, and cannot be written to.
	// This means 'v' and 'i' are constant.


	for v, i in array {
		if v & 1 == 1 {
			break
		}
		fmt.println("Regular iterator:", v, i)
	}


	// Custom iterator without index returned.
	i := 0
	for v in iter1(i, array[:]) {
		fmt.println("Custom iterator, value only:", v, i)
		i += 1
	}


	// Custom iterator with index returned (don't do this).
	k := 0
	for v, i in iter2(k, array[:]) {
		fmt.println("Custom iterator, value and index:", v, i)
		k = i + 1
	}


	// Custom iterator with structure returned (recommended).
	is := iter_struct{data = array[:], index = 0}
	for v, idx in iter3(&is) {
		fmt.println("Custom iterator, struct:", v, idx)
	}
}

/* Output:
Regular iterator: 2 0
Regular iterator: 4 1
Regular iterator: 6 2
Regular iterator: 8 3
Custom iterator, value only: 2 0
Custom iterator, value only: 4 1
Custom iterator, value only: 6 2
Custom iterator, value only: 8 3
Custom iterator, value and index: 2 0
Custom iterator, value and index: 4 1
Custom iterator, value and index: 6 2
Custom iterator, value and index: 8 3
Custom iterator, struct: 2 0
Custom iterator, struct: 4 1
Custom iterator, struct: 6 2
Custom iterator, struct: 8 3
*/
