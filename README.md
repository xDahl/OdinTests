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
