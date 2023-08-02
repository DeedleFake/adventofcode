package main

import (
	"day04/internal/iter"
	"fmt"
	"io"
	"os"
	"strconv"
)

func Calories(r io.Reader, err *error) iter.Iter[int] {
	return func(yield func(int) bool) bool {
		var cur int
		for line := range iter.Lines(r, err) {
			if len(line) == 0 {
				if !yield(cur) {
					return false
				}
				cur = 0
				continue
			}
			v, _ := strconv.ParseInt(line, 10, 0)
			cur += int(v)
		}
		if cur != 0 {
			yield(cur)
		}
		return false
	}
}

func count(get func(iter.Iter[int]) int) {
	file, err := os.Open(os.Args[1])
	if err != nil {
		panic(err)
	}
	defer file.Close()

	fmt.Println(get(Calories(file, &err)))
	if err != nil {
		panic(err)
	}
}

func main() {
	count(iter.Max[int])
	count(func(i iter.Iter[int]) int { return iter.Sum(iter.Slice(iter.MaxN(i, 3))) })
}
