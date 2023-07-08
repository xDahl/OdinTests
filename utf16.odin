/* My first time writing a UTF-16 encoder/decoder.
 * And I gotta say, UTF-16 SSUUUUUUUUUUCCCCKKKKSS.
 * In my implementation, the endianness of my
 * encoder/decoder defaults to the system.
 * So for all practical purposes, since we all run x86/64,
 * Little-Endian.
 * My code here also does next to no error/safety handling. */

package main

import "core:fmt"
import "core:runtime"


INVALID_RUNE  ::  -1


utf16_decode :: proc(b : []u8, e := ODIN_ENDIAN) -> (r : rune, l : int)
{
	seq : struct #raw_union {
		b : [4]u8
		u : [2]u16
	}

	if len(b) < 2 {
		return INVALID_RUNE, 2
	}

	seq.u[0]  = cast(u16)b[0]
	seq.u[0] |= cast(u16)b[1] << 8

	if ODIN_ENDIAN != e {
		seq.b[0], seq.b[1] = seq.b[1], seq.b[0]
	}

	if seq.u[0] >= 0xD800 && seq.u[0] < 0xDC00 {
		if len(b) < 4 {
			return INVALID_RUNE, 2
		}

		l = 4

		seq.u[1]  = cast(u16)b[2]
		seq.u[1] |= cast(u16)b[3] << 8

		if ODIN_ENDIAN != e {
			seq.b[3], seq.b[2] = seq.b[2], seq.b[3]
		}

		r  = cast(rune)(seq.u[0] - 0xD800) << 10
		r += cast(rune)(seq.u[1] - 0xDC00) + 0x10_000
	} else {
		l = 2
		r = cast(rune)seq.u[0]
	}

	return
}

utf16_encode :: proc(b : []u8, r : rune, e := ODIN_ENDIAN) -> (l : int)
{
	seq : struct #raw_union {
		b : [4]u8  // Byte.
		u : [2]u16 // Code unit.
	}

	switch r >= 0x10_000 {
	case false:
		if len(b) < 2 {
			return 0
		}
		l = 2 // Two byte encoding.
		seq.u[0] = cast(u16)r
	case true:
		if len(b) < 4 {
			return 0
		}
		l = 4 // Four byte encoding.
		bits := r - 0x10_000
		seq.u[0] = cast(u16)((bits  >>  10) | 0xD800)
		seq.u[1] = cast(u16)((bits & 0x3FF) | 0xDC00)
	}

	if ODIN_ENDIAN != e {
		seq.b[0], seq.b[1] = seq.b[1], seq.b[0]
		seq.b[2], seq.b[3] = seq.b[3], seq.b[2]
	}

	for i := 0; i < l; i += 1 {
		b[i] = seq.b[i]
	}

	return
}

main :: proc()
{
	validate :: proc(r : rune, e := runtime.Odin_Endian_Type.Little)
	{
		using fmt

		b : [4]u8
		i : int
		l := utf16_encode(b[:], r, e)

		printf("U+%5X  %ce  ", r, e == .Little ? 'L' : 'B')
		for i = 0; i < l; i += 1 {
			printf("%2X ", b[i])
		}
		for ; i < 4; i += 1 {
			printf("   ")
		}

		dr, dl := utf16_decode(b[:], e)
		printf(" U+%5X  %t\n", dr, r == dr);
	}

	test :: proc(r : rune)
	{
		validate(r)
		validate(r, ODIN_ENDIAN == .Little ? .Big : .Little)
	}

	test('A')
	test(0x20A0)
	test(0xFFFD)

	test(0x10437)
	test(0x24b62)
	test(0x1F600)
}

/* Output:
U+00041  Le  41 00        U+00041  true
U+00041  Be  00 41        U+00041  true
U+020A0  Le  A0 20        U+020A0  true
U+020A0  Be  20 A0        U+020A0  true
U+0FFFD  Le  FD FF        U+0FFFD  true
U+0FFFD  Be  FF FD        U+0FFFD  true
U+10437  Le  01 D8 37 DC  U+10437  true
U+10437  Be  D8 01 DC 37  U+10437  true
U+24B62  Le  52 D8 62 DF  U+24B62  true
U+24B62  Be  D8 52 DF 62  U+24B62  true
U+1F600  Le  3D D8 00 DE  U+1F600  true
U+1F600  Be  D8 3D DE 00  U+1F600  true
*/
