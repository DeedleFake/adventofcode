package main

import (
	"day04/internal/iter"
	"fmt"
	"os"
	"strconv"
	"strings"
)

func parseRange(str string) (start, end int) {
	s, e, _ := strings.Cut(str, "-")
	sn, _ := strconv.ParseInt(s, 10, 0)
	en, _ := strconv.ParseInt(e, 10, 0)
	return int(sn), int(en)
}

func checkLine(line string) bool {
	left, right, _ := strings.Cut(line, ",")
	l1, l2 := parseRange(left)
	r1, r2 := parseRange(right)

	return ((l1 >= r1) && (l2 <= r2)) || ((r1 >= l1) && (r2 <= l2))
}

func main() {
	file, err := os.Open(os.Args[1])
	if err != nil {
		panic(err)
	}
	defer file.Close()

	var total int
	for line := range iter.Lines(file, &err) {
		if checkLine(line) {
			total++
		}
	}
	if err != nil {
		panic(err)
	}

	fmt.Println(total)
}
