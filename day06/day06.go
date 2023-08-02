package main

import (
	"adventofcode/internal/iter"
	_ "embed"
	"fmt"
)

//go:embed input.txt
var input string

func uniq(s []byte) bool {
	for i, c := range s[:len(s)-1] {
		if iter.Any(iter.Slice(s[i+1:]), func(c2 byte) bool { return c == c2 }) {
			return false
		}
	}
	return true
}

func Count(n int) int {
	return iter.Count(iter.TakeUntil(iter.Windows(iter.Bytes(input), n), uniq)) + n
}

func Part1() int {
	return Count(4)
}

func Part2() int {
	return Count(14)
}

func main() {
	fmt.Println(Part1())
	fmt.Println(Part2())
}
