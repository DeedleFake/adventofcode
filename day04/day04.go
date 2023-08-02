package main

import (
	"day04/internal/iter"
	"fmt"
	"os"
	"strconv"
	"strings"
)

type Line struct {
	L, R [2]int
}

func ParseLine(line string) Line {
	left, right, _ := strings.Cut(line, ",")
	return Line{
		L: parseRange(left),
		R: parseRange(right),
	}
}

func parseRange(str string) [2]int {
	s, e, _ := strings.Cut(str, "-")
	sn, _ := strconv.ParseInt(s, 10, 0)
	en, _ := strconv.ParseInt(e, 10, 0)
	return [2]int{int(sn), int(en)}
}

func isSubset(line Line) bool {
	return ((line.L[0] >= line.R[0]) && (line.L[1] <= line.R[1])) ||
		((line.R[0] >= line.L[0]) && (line.R[1] <= line.L[1]))
}

func overlaps(line Line) bool {
	return (line.L[1] >= line.R[0]) && (line.R[1] >= line.L[0])
}

func count(check func(Line) bool) {
	file, err := os.Open(os.Args[1])
	if err != nil {
		panic(err)
	}
	defer file.Close()

	data := iter.Filter(
		iter.Map(
			iter.Lines(file, &err),
			ParseLine,
		),
		check,
	)

	total := iter.Count(data)
	if err != nil {
		panic(err)
	}

	fmt.Println(total)
}

func main() {
	count(isSubset)
	count(overlaps)
}
