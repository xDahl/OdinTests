package main

import "core:fmt"

error_code :: enum {
	/* To make it easier to understand how 'or_return' works,
	 * I've split the enum for no-error into two.
	 * 1: One to signify nothing bad happened,
	 * 2: One to signify the same, but to show which return statement executed. */
	ERROR_NONE = 0,
	ERROR_NONE_END_OF_PROCEDURE,

	ERROR_BAD,
	ERROR_WORSE,
}

main :: proc()
{
	using fmt

	print_single :: proc(n : int)
	{
		printf("Single return: %d -> %s\n", n, single_return(n))
	}

	print_single(0)
	print_single(5)
	print_single(9)
	print_single(15)
	print_single(30)


	print_multiple :: proc(n : int)
	{
		printf("Multiple return: %d -> %d %d %t\n", n, multiple_return(n))
	}

	println("")
	print_multiple(0)
	print_multiple(5)
	print_multiple(9)
	print_multiple(20)



	/* 'or_else' also works by checking the last return value,
	 * but instead of using the last return value,
	 * it's used to alter the other values before it. */
	m := make(map[string]int)

	m["valid"] = 10
	n := m["valid"]

	k := m["hello"] or_else 42
	/* Same as:
	 * k, ok := m["hello"]
	 * if ok == false {
	 * 	k = 42
	 * }
	 * ...
	 * */
	println("")
	println("'or_else' test, N & K: ", n, k)

	// We can also use the 'or_else' via our own procedures as well.

	times_ten :: proc(n : int) -> (int, bool)
	{
		if n > 0 {
			return n * 10, true
		} else {
			return 0, false
		}
	}

	k = times_ten(5) or_else -1
	println("times_ten(5): ", k)

	k = times_ten(0) or_else -1
	println("times_ten(0): ", k)
}

single_return :: proc(n : int) -> error_code
{
	return_enum :: proc(n : int) -> error_code
	{
		switch n {
		case 0..=9  : return .ERROR_NONE // Can also return 'nil'.
		case 10..=20: return .ERROR_BAD
		case        : return .ERROR_WORSE
		}
	}

	/* 'or_return' basically takes the last return value,
	 * in this case, an enum,
	 * and returns that value if it's non-zero
	 * (ERROR_NONE or 'nil', as nil can also be used to indicate no error). */

	// The way I like to think about the keyword is as such:
	return_enum(n) or_return // 'or_return' error if error.

	/* If .ERROR_NONE or nil was returned above,
	 * the 'or_return' expression would not return anything.
	 * The above code is equivilant to: */
	/* e := return_enum(n)
	 * if e != 0 { // nil == 0 and .ERROR_NONE == 0
	 * 	return e
	 * }
	 * ...
	 * */

	/* Returning the distinct no-error enum to show
	 * that this return statement was executed,
	 * and that 'or_return' didn't return. */
	return .ERROR_NONE_END_OF_PROCEDURE
}

multiple_return :: proc(n : int) -> (k, m : int, ok : bool)
{
	return_bool :: proc(n : int) -> (int, int, bool)
	{
		switch n {
		case 0..=9: return  n,  n * 10, true
		case      : return -1, -1     , false
		}
	}

	/* Like above, this will take the last return value
	 * and return early if it is 'false' (an error).
	 * for this to work, the return values have to be named afaik.
	 *
	 * So, any number from 0 to 9 will return
	 * the number as-is, ten times that number and true. */
	k, m = return_bool(n) or_return

	/* Something interesting happens on returning
	 * multiple values and false tho, -1 isn't returned!
	 * The 'or_return' above is equivilant to: */
	/* new_k, new_m, ok = return_bool(n)
	 * if ok == false {
	 * 	// NB: k & m not set to the return values yet!
	 * 	return k, m, false
	 * }
	 * k = new_k // new_k = -1
	 * m = new_m // new_k = -1
	 * ...
	 * */

	return k, m, true
}

/* Output:
Single return: 0 -> ERROR_NONE_END_OF_PROCEDURE
Single return: 5 -> ERROR_NONE_END_OF_PROCEDURE
Single return: 9 -> ERROR_NONE_END_OF_PROCEDURE
Single return: 15 -> ERROR_BAD
Single return: 30 -> ERROR_WORSE

Multiple return: 0 -> 0 0 true
Multiple return: 5 -> 5 50 true
Multiple return: 9 -> 9 90 true
Multiple return: 20 -> 0 0 false

'or_else' test, N & K:  10 42
times_ten(5):  50
times_ten(0):  -1
*/
