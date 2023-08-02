package main_test

import (
	main "adventofcode/day01"
	"testing"

	"gotest.tools/v3/assert"
)

func TestPart1(t *testing.T) {
	assert.Equal(t, 68787, main.Part1())
}

func TestPart2(t *testing.T) {
	assert.Equal(t, 198041, main.Part2())
}
