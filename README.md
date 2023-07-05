# Why are you here? :P

This rep is just for me to post dumb testing code I've written while learning Odin.

Extra things I've noticed/found/(had to look up because it wasn't stated in the official documentation) in Odin:
```text
strings are immutable.
s : string = "hi"
s[0] = 0 // Invalid

There is a built-in alias for bytes:
byte :: u8

extra resources one ought to check out:
https://github.com/odin-lang/Odin/blob/master/core/builtin/builtin.odin
https://github.com/odin-lang/examples
```


array_n_maps.odin output:
```text
Dynamic array testing:
        0 = 0
        1 = 3
        2 = 6
        3 = 9
        4 = 12
        5 = 15
        6 = 18
        7 = 21
        8 = 24
        9 = 27
        0 = 12 'this is cool'
        1 = 12 'or something'
        2 = 06 'right?'
        str: len = 3    cap = 12
Map testing:
        "test" = 0      (exists: false)
        "test" = 42     (exists: true)
        "hello" = ""    (exists: false)
        "hello" = "world"       (exists: true)
Static array testing:
        [00] [01] [02] [03] [04] [05] [06] [07] [08] [09]
         03   03   03   00   00   10   10   10   10   10
         00   00   00   00   00   00   00   00   00   00
         00   00   00   00   00   00   00   00   00   00
         00   00   00   00   00   00   00   00   00   00
         00   00   00   00   00   00   00   00   00   00
         55   55   55   55   55   55   55   55   55   55
         55   55   55   55   55   55   55   55   55   55
         55   55   55   55   55   55   55   55   55   55
         55   55   55   55   55   55   55   55   55   55
         55   55   55   55   55   55   55   55   55   55
```

utf8.odin output:
```text
Rune count: 3 : ABC
Rune count: 3 : äbè
Rune count: 5 : Hell�o
Decode tests:
7F          = Length: 1 = U+7F
31          = Length: 1 = U+31
41          = Length: 1 = U+41
C3 84       = Length: 2 = U+C4
84          = Length: 1 = U+FFFFFFFFFFFFFFFF
C3 B4       = Length: 2 = U+F4
E2 9B 80    = Length: 3 = U+26C0
F0          = Length: 1 = U+FFFFFFFFFFFFFFFF
F2 90 BC 82 = Length: 4 = U+90F02
Decode iteration test:
[ U+31 U+32 U+FFFFFFFFFFFFFFFF U+33 ] = "12�3"
Encode tests:
61          true    Encode: U+61        ->  Decode: U+61
7F          true    Encode: U+7F        ->  Decode: U+7F
C2 80       true    Encode: U+80        ->  Decode: U+80
DF BF       true    Encode: U+7FF       ->  Decode: U+7FF
E0 A0 80    true    Encode: U+800       ->  Decode: U+800
E2 94 80    true    Encode: U+2500      ->  Decode: U+2500
EF BF BD    true    Encode: U+FFFD      ->  Decode: U+FFFD
F0 90 80 80 true    Encode: U+10000     ->  Decode: U+10000
F4 8F BF BF true    Encode: U+10FFFF    ->  Decode: U+10FFFF
```

custom_iterators.odin:
```text
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
```

swizzles_and_overloading.odin:
```text
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
```

or_else_return.odin:
```text
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
```

bitsets.odin:
```text
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
```
