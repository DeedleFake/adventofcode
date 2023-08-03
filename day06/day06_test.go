package main_test

import (
	main "adventofcode/day06"
	"testing"

	"gotest.tools/v3/assert"
)

func TestPart1(t *testing.T) {
	assert.Equal(t, 1262, main.Part1())
}

func TestPart2(t *testing.T) {
	assert.Equal(t, 3444, main.Part2())
}

func BenchmarkDeedleFake(b *testing.B) {
	for range b.N {
		main.Count(14)
	}
}

func BenchmarkOriginal(b *testing.B) {
	for range b.N {
		main.Original()
	}
}
