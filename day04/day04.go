package main

import (
	"adventofcode/internal/iter"
	_ "embed"
	"fmt"
	"strconv"
	"strings"
)

//go:embed input.txt
var input string

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

func IsSubset(line Line) bool {
	return ((line.L[0] >= line.R[0]) && (line.L[1] <= line.R[1])) ||
		((line.R[0] >= line.L[0]) && (line.R[1] <= line.L[1]))
}

func Overlaps(line Line) bool {
	return (line.L[1] >= line.R[0]) && (line.R[1] >= line.L[0])
}

func Count(check func(Line) bool) int {
	file := strings.NewReader(input)

	var err error
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
	return total
}

func Part1() int {
	return Count(IsSubset)
}

func Part2() int {
	return Count(Overlaps)
}

func main() {
	fmt.Println(Part1())
	fmt.Println(Part2())
}
