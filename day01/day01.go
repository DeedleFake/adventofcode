package main

import (
	"adventofcode/internal/iter"
	_ "embed"
	"fmt"
	"io"
	"strconv"
	"strings"
)

//go:embed input.txt
var input string

func Calories(r io.Reader, err *error) iter.Iter[int] {
	return func(yield func(int) bool) bool {
		var cur int
		for line := range iter.Lines(r, err) {
			if len(line) > 0 {
				v, _ := strconv.ParseInt(line, 10, 0)
				cur += int(v)
				continue
			}
			if !yield(cur) {
				return false
			}
			cur = 0
		}
		if cur != 0 {
			yield(cur)
		}
		return false
	}
}

func Count(get func(iter.Iter[int]) int) {
	file := strings.NewReader(input)

	var err error
	fmt.Println(get(Calories(file, &err)))
	if err != nil {
		panic(err)
	}
}

func main() {
	Count(iter.Max[int])
	Count(func(i iter.Iter[int]) int { return iter.Sum(iter.Slice(iter.MaxN(i, 3))) })
}
