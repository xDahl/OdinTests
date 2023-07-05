package main

import "core:fmt"

SHORT :: enum {
	A,
	B,
	C,
	D,
	E,
	F,
}

LONG :: enum {
	A, B, C, D, E, F, G, H, I, J, K, L
}
/* In Odin, much like C, the first enum starts with the
 * value 0, and increments.
 * So A would be 0, B would be 1, C would be 2, etc.
 * Bitsets lets you treat each enum as if it were a flag for a single bit,
 * rather than a number that increments (a counter).
 * So by doing 'var : bit_set[SHORT] = {.A, .B, .C}'
 * You're saying that A would be a bit,
 * B would be a different bit, and C another distinct bit.
 * In order to treat enums in C as bit for bit checking,
 * you would have to do something like this:
 * enum SHORT {
 * 	A = 1 << 0,
 * 	B = 1 << 1,
 * 	C = 1 << 2,
 * 	D = 1 << 3,
 * 	E = 1 << 4,
 * 	F = 1 << 5,
 * }
 * Bitsets allows you to reuse an enum without all this
 * typing nonsense, and it simplifies bit operations.
 * The size of the bitset variable will be as big as it needs to be
 * for the number of enums available, you can overwrite this by doing:
 * var : bit_set[ENUM; u16]
 * */

main :: proc()
{
	basics()
	fmt.printf("\n\n")
	comps()
	fmt.printf("\n\n")
	bonus()
}


basics :: proc()
{
	using fmt

	println("Basics:")

	// Enum containing 'SHORT.A'.
	e : SHORT = .A

	// Bitset containing the '.A' as a bit.
	// I didn't have to look up how to use declare a bitset,
	// Odin's syntax was pretty intuitive  :)
	b : bit_set[SHORT] = {.A, .C, .D, .F}

	println("\tb:", b)
	if SHORT.A in b {
		println("\tSHORT.A is in b")
	}
	if .B not_in b {
		println("\tSHORT.B is not in b")
	}


	// We cannot have a bitset bigger than 128 bits, sadly.
	// too_many := bit_set[0..=200]{}
	// If you need THIS many bits, I think your best bet is
	// an array of ints, and using indexing and modulo
	// to the bit you need.
	// Best to avoid that sceneario if possible.


	// Impliccitely this will be a bit_set of runes.
	r : bit_set['a'..='z']
	println("\tr:", r)
	r |= {'a', 'f'}
	r |= {cast(rune)100} // We need to cast this untyped interger to a rune.
	println("\tr:", r)

	// Whereas this will be a bit_set of ints.
	i : bit_set[97..=122]
	println("\ti:", i)
	i += {'a', 'f'}
	i += {100}
	println("\ti:", i)


	// Unfortunately, we cannot iterate over bitsets.
	/* for v in i {
	 * ...
	 * }
	 * */
}

comps :: proc()
{
	using fmt

	println("Comps:")

	a : bit_set[SHORT] = {.B, .D, .E}
	b := bit_set[SHORT]{.A, .B, .C, .D, .E}
	r := bit_set[SHORT]{.B, .F}

	println("\ta:", a)
	println("\tb:", b)
	println("\tr:", r)

	println("")
	println("\ta == b", a == b, "(A is equal to B)")
	println("\ta < b", a < b, "(A is a (strict) subset of B)")
	println("\tb > a", b > a, "(B is a (strict) superset of A)")
	println("\ta > b", a > b, "(A is a (strict) superset of B)")
	println("\tb < a", b < a, "(B is a (strict) subset of A)")
	println("")
	println("\tA being a subset of B means that every element in A is in B as well.")
	println("\tNo order of elements is required for this to be true.")
	println("")
	println("\tb == b", b == b, "(B is equal to B)")
	println("\tb < b", b < b, "(B is a (strict) subset of B)")
	println("\tb <= b", b <= b, "(B is a subset of/or equal to B)")
	println("")
	println("\tr < b", r < b, "(R is a (strict) subset of B)")
	println("\tFalse because R contains an element B does not.")
	println("")
	println("\tElements A and B share:", a & b)
	println("\tElements A and R share:", a & r)
	println("\tElements B and R share:", b & r)
	println("\tElements A and B differences:", a &~ b)
	println("\tElements A and R differences:", a &~ r)
	println("\tElements B and R differences:", b &~ r)
	println("\t'+' in bitsets is the same as '|'")
	println("\t'-' in bitsets is the same as '&~'")
	println("\tR and B combined (r | b):", r | b)
	println("\tR and B combined (r + b):", r + b)
	println("\tR removed from B (b - r):", b - r)
	println("\tR removed from B (b &~ r):", b &~ r)
	println("")
	println("\tlike len(...) & cap(...), there's 'card(...)'.")
	println("\tA's cardinality (Number of elements):", card(a))
	println("\tB's cardinality (Number of elements):", card(b))
	println("\tR's cardinality (Number of elements):", card(r))
}

bonus :: proc()
{
	using fmt

	println("Bonus:")

	// Telling Odin to only use 8 bits for this bitset.
	a := bit_set[SHORT; u8]{.B, .E}

	b := bit_set[0..<8; u8]{0, 1, 2, 3}
	b += bit_set[0..<8; u8]{4, 5, 6, 7}

	// Or if you prefer 1-8 instead of 0-7
	c := bit_set[1..=8; u8]{1, 2, 3, 4, 5, 6, 7, 8}

	println("\ta:", a)
	println("\tb:", b)
	println("\tc:", c)
	println("\tSHORT.B =", transmute(u8)bit_set[SHORT; u8]{.B})
	println("\tSHORT.E =", transmute(u8)bit_set[SHORT; u8]{.E})
	println("\ta value:", transmute(u8)a)
	println("\tb value:", transmute(u8)b)
	println("\tc value:", transmute(u8)c)


	printf("\n\tbit_set[SHORT] = %d bits", size_of(bit_set[SHORT]) * 8)
	printf("\n\tbit_set[SHORT; u16] = %d bits", size_of(bit_set[SHORT; u16]) * 8)
	printf("\n\tbit_set[LONG] = %d bits\n", size_of(bit_set[LONG]) * 8)
}

/* Output:
Basics:
	b: bit_set[SHORT]{A, C, D, F}
	SHORT.A is in b
	SHORT.B is not in b
	r: bit_set['a'..='z']{}
	r: bit_set['a'..='z']{97, 100, 102}
	i: bit_set[97..=122]{}
	i: bit_set[97..=122]{97, 100, 102}


Comps:
	a: bit_set[SHORT]{B, D, E}
	b: bit_set[SHORT]{A, B, C, D, E}
	r: bit_set[SHORT]{B, F}

	a == b false (A is equal to B)
	a < b true (A is a (strict) subset of B)
	b > a true (B is a (strict) superset of A)
	a > b false (A is a (strict) superset of B)
	b < a false (B is a (strict) subset of A)

	A being a subset of B means that every element in A is in B as well.
	No order of elements is required for this to be true.

	b == b true (B is equal to B)
	b < b false (B is a (strict) subset of B)
	b <= b true (B is a subset of/or equal to B)

	r < b false (R is a (strict) subset of B)
	False because R contains an element B does not.

	Elements A and B share: bit_set[SHORT]{B, D, E}
	Elements A and R share: bit_set[SHORT]{B}
	Elements B and R share: bit_set[SHORT]{B}
	Elements A and B differences: bit_set[SHORT]{}
	Elements A and R differences: bit_set[SHORT]{D, E}
	Elements B and R differences: bit_set[SHORT]{A, C, D, E}
	'+' in bitsets is the same as '|'
	'-' in bitsets is the same as '&~'
	R and B combined (r | b): bit_set[SHORT]{A, B, C, D, E, F}
	R and B combined (r + b): bit_set[SHORT]{A, B, C, D, E, F}
	R removed from B (b - r): bit_set[SHORT]{A, C, D, E}
	R removed from B (b &~ r): bit_set[SHORT]{A, C, D, E}

	like len(...) & cap(...), there's 'card(...)'.
	A's cardinality (Number of elements): 3
	B's cardinality (Number of elements): 5
	R's cardinality (Number of elements): 2


Bonus:
	a: bit_set[SHORT; u8]{B, E}
	b: bit_set[0..=7; u8]{0, 1, 2, 3, 4, 5, 6, 7}
	c: bit_set[1..=8; u8]{1, 2, 3, 4, 5, 6, 7, 8}
	SHORT.B = 2
	SHORT.E = 16
	a value: 18
	b value: 255
	c value: 255

	bit_set[SHORT] = 8 bits
	bit_set[SHORT; u16] = 16 bits
	bit_set[LONG] = 16 bits
*/
