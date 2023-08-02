package main_test

import (
	main "adventofcode/day04"
	"testing"

	"gotest.tools/v3/assert"
)

func TestPart1(t *testing.T) {
	assert.Equal(t, 540, main.Part1())
}

func TestPart2(t *testing.T) {
	assert.Equal(t, 872, main.Part2())
}
