/* I am well aware that Odin has native UTF-8 procedures,
 * I wrote this as a way to learn Odin, through experimentation & usage.
 * Don't use this code for anything, it's probably wrong anyway.
 *
 * There is a good reason to use your own UTF-8 procedures over Odin's;
 * Besides optimizations for your usecase, there's also the fact
 * that Odin will use the U+FFFD character on errors,
 * but users could intentionally use that character for fun,
 * so unless you check the encoding in the string yourself;
 * you won't know if it WAS an error or if the U+FFFD character was there.
 * It all depends on your usecase and needs. */

package main

import "core:fmt"


INVALID_RUNE  ::  -1


/* UTF-8 Header lengths.
 * 80-BF can be commented out, as uninitialized values are zero by default.
 * But I'm keeping it for clarity. */
utf8_hlen := [256]int{
	0x00..=0x7F = 1,  // ASCII.
	0x80..=0xBF = 0,  // Continuation bytes.
	0xC0..=0xC1 = -1, // Invalid 2 byte ASCII.
	0xC2..=0xDF = 2,  // Two byte encoding.
	0xE0..=0xEF = 3,  // Three byte encoding.
	0xF0..=0xF4 = 4,  // Four byte encoding.
	0xF5..=0xFF = -1  // Overlong encodings.
}

rune_utf8_len :: proc(r : rune) -> int
{
	/* I doubt the compiler would generate a jump-table here,
	 * if it does, I will cry ;-; */
	switch r {
	case 0x00000..<0x00080:  return 1
	case 0x00080..<0x00800:  return 2
	case 0x00800..<0x10000:  return 3
	case 0x10000..=0x10FFFF: return 4
	}
	return 0
}


/* Strings in Odin are basically slices to an u8 array,
 * but you can't treat it as one, and we don't have C like macros in Odin.
 * So how would one write a procedure to handle both arrays and strings?
 * Well, explicit operator overloading combined with forced inlining
 * would basically produce the same as a C macro without duplicate code.
 * This feels jank as butter, and would not play well if you needed
 * more than one string argument, but this works, and is what Odin
 * does internally for its UTF-8 procedures. */


// Handles overlong encodings and invalid ranges,
// returns decoded rune and encoding length,
// on error length is 1 for safe iterations.
utf8_decode :: proc{ utf8_decode_string, utf8_decode_bytes }

utf8_decode_string :: #force_inline proc(s : string) -> (rune, int)
{
	return utf8_decode_bytes(transmute([]u8)s)
}

utf8_decode_bytes :: proc(b : []u8) -> (r : rune, l : int)
{
	bits := [?]rune{0x7F, 0x7F, 0x1F, 0x0F, 0x07}

	if l = utf8_hlen[b[0]]; l >= 1 && l <= 4 {
		if l > len(b) {
			return INVALID_RUNE, 1
		}

		r = cast(rune)b[0] & bits[l]
		for i := 1; i < l; i += 1 {
			if b[i] & 0xC0 != 0x80 {
				return INVALID_RUNE, 1
			}

			r = (r << 6) + rune(b[i]) & 0x3F
		}

		if rune_utf8_len(r) != l || (r >= 0xD800 && r <= 0xDFFF) {
			return INVALID_RUNE, 1
		}

		return // Naked return, same as 'return r, l'
	}

	return INVALID_RUNE, 1
}

// Note: Does not validate the rune before encoding,
// just assumes the rune is within a valid range.
// Returns amount of bytes written, 0 on error.
utf8_encode :: proc(b : []u8, r : rune) -> int
{
	bits := []u8{0, 0, 0xC0, 0xE0, 0xF0}
	r := r // Arguments are const by default, marking this as mutable.

	l := rune_utf8_len(r)

	if l > len(b) || l == 0 {
		return 0
	}

	for i := 1; i < l; i += 1 {
		b[l-i] = 0x80 | (cast(u8)r & 0x3F)
		r >>= 6
	}
	b[0] = u8(r) | bits[l]

	return l
}


// I made this for fun, does no rune validation at all.
rune_count :: proc{rune_count_string, rune_count_bytes}

rune_count_string :: #force_inline proc(s : string) -> int
{
	return rune_count_bytes(transmute([]u8)s)
}

rune_count_bytes :: proc(b : []u8) -> (count : int)
{
	for i := 0; i < len(b); {
		switch l := utf8_hlen[b[i]]; l {
		case 1..=4:
			count += 1
			i += l
		case:
			i += 1
		}
	}

	return
}

main :: proc()
{
	using fmt

	runes :: proc(s : string)
	{
		println("Rune count:", rune_count(s), ":", s)
	}

	when ODIN_OS == .Windows {
		println("Output may be broken due to console using codepages, I don't care to fix.")
	}
	runes("ABC")
	runes("äbè")
	runes("Hell\x80o")


	print_utf8 :: proc(s : string)
	{
		r, l := utf8_decode(s)

		i := 0
		for ; i < l; i += 1 { printf("%2X ", s[i]) }
		for ; i < 4; i += 1 { printf("   ") }

		printf("= Length: %d = U+%X\n", l, r)
	}

	println("Decode tests:")
	print_utf8("\x7F")
	print_utf8("1")
	print_utf8("A")
	print_utf8("Äô")
	print_utf8("Äô"[1:])
	print_utf8("Äô"[2:])
	print_utf8("\xE2\x9b\x80")
	print_utf8("\xF0\x80\x80\x80")
	print_utf8("\xF2\x90\xbc\x82")

	iterate :: proc(s : string)
	{
		printf("[ ")
		for i := 0; i < len(s); {
			r, l := utf8_decode(s[i:])
			i += l
			printf("U+%X ", r)
		}
		printf("] = \"%s\"\n", s)
	}

	println("Decode iteration test:")
	iterate("12\xE03")


	encode :: proc(r : rune)
	{
		buff : [4]u8
		utf8_encode(buff[:], r)

		decode, l := utf8_decode(buff[:])

		i := 0
		for ; i < l; i += 1 { printf("%2X ", buff[i]) }
		for ; i < 4; i += 1 { printf("   ") }
		printf("%t    Encode: U+%X\t->  Decode: U+%X\n",
			r == decode, r, decode)
	}

	println("Encode tests:")
	encode('a')
	encode('\x7F')
	encode(0x80)
	encode(0x7FF)
	encode(0x800)
	encode(0x2500)
	encode(0xFFFD)
	encode(0x10000)
	encode(0x10FFFF)
}
