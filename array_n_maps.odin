package main

import "core:fmt"


testarray :: proc()
{
	using fmt

	// fmt.println("Dynamic array testing:")
	println("Dynamic array testing:")

	arr : [dynamic]int
	defer delete(arr)
	
	for i := 0; i < 10; i += 1 {
		append(&arr, i * 3)
	}

	i := 0
	for v in arr {
		printf("\t%d = %d\n", i, v)
		i += 1
	}


	// str : [dynamic]string
	// Same as above, but set the capacity to 2 elements.
	// Note: Appending more than the capacity will allocate more :)
	// Capacity is not fixed! It's more for optimizations.
	str := make([dynamic]string, 0, 2)
	defer delete(str)
	
	append(&str, "this is cool")
	append(&str, "or something")
	append(&str, "right?")
	
	/*for s in str {
		fmt.printf("'%s'\n", s);
	}*/
	for i := 0; i < len(str); i += 1 {
		printf("\t%d = %2d '%s'\n", i, len(str[i]), str[i])
	}
	printf("\tstr: len = %d    cap = %d\n", len(str), cap(str))
}

testmaps :: proc()
{
	using fmt

	println("Map testing:")
	
	
	intpri := proc(m : map[string]int, s : string)
	{
		v, ok := m[s]
		printf("\t\"%s\" = %d\t(exists: %t)\n", s, v, ok)
	}
	m := make(map[string]int, 4)
	defer delete(m)

	intpri(m, "test")
	m["test"] = 42
	intpri(m, "test")
	
	
	strpri := proc(m : map[string]string, s : string)
	{
		v, ok := m[s]
		printf("\t\"%s\" = \"%s\"\t(exists: %t)\n", s, v, ok)
	}
	
	list := make(map[string]string)
	defer delete(list)
	
	strpri(list, "hello")
	list["hello"] = "world"
	strpri(list, "hello")
}

main :: proc()
{
	using fmt

	testarray()
	testmaps()
	
	// Just some extra stuff for fun.
	println("Static array testing:")
	
	// THIS is just awesome!
	arr := [?]int{0..<3 = 3, 5..<10 = 10, 50..=99 = 55}
	
	printf("\t")
	for i := 0; i < 10; i += 1 {
		printf("[%2d] ", i)
	}
	for i := 0; i < len(arr); i += 1 {
		if i % 10 == 0 {
			printf("\n\t")
		}
		
		printf(" %2d  ", arr[i])
	}

	printf("\n")
}

/* Output:
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
*/
