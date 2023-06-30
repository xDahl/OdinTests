/* Given that I don't have to define a prodecure/function
 * before using it in Odin, unlike in C;
 * I will be trying to have the main procedure at the top
 * going forward. Just C habits. */

package main

import "core:fmt"


// Explicit procedure overloading.
to_num :: proc{to_num_bool, to_num_string, to_num_int}

// Force inlined to remove prodecure call.
to_num_bool :: #force_inline proc(b : bool) -> int
{
	return (b) ? 1 : 0
}

// Not force inlining this one, just because :)
to_num_string :: proc(s : string) -> (r : int)
{
	for i := 0; i < len(s); i += 1 {
		if s[i] >= '0' && s[i] <= '9' {
			r = r * 10 + int(s[i]) - '0'
			// Different way of casting:
			// r = r * 10 + cast(int)s[i] - '0'
		} else {
			break
		}
	}

	return
}

// Force inlined to remove prodecure call.
to_num_int :: #force_inline proc(n : int) -> int
{
	return n
}

main :: proc()
{
	fmt.println(to_num(false), to_num(true))
	fmt.println(to_num(""), to_num("123"), to_num("123.22"))
	fmt.println(to_num(0), to_num(123))


	// swizzles are basically just array reordering.
	// Usefor graphics programming, apparently.

	a : [5]int = {1, 2, 3, 4, 5}
	b := [5]int{0..<5 = 2} // {2, 2, 2, 2, 2}

	pri("a", a[:])
	pri("b", b[:])

	c := a * b
	pri("c = a*b", c[:])

	d := a + a * c
	pri("d = a + a * c", d[:])

	e := swizzle(a, 4, 3, 2, 1, 0)
	pri("e = swizzle(a, 4, 3, 2, 1, 0)", e[:])

	f := swizzle(a, 4, 1, 3, 0, 2)
	pri("f = swizzle(a, 4, 1, 3, 0, 2)", f[:])
}

pri :: proc(s : string, a : []int) {
	using fmt

	printf("%s:\n\t", s)
	for i in a {
		printf("%d ", i)
	}
	printf("\n\n")
}

/* Output:
0 1
0 123 123
0 123
a:
        1 2 3 4 5

b:
        2 2 2 2 2

c = a*b:
        2 4 6 8 10

d = a + a * c:
        3 10 21 36 55

e = swizzle(a, 4, 3, 2, 1, 0):
        5 4 3 2 1

f = swizzle(a, 4, 1, 3, 0, 2):
        5 2 4 1 3
*/
