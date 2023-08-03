package main

import (
	"adventofcode/internal/iter"
	"math/bits"
)

// This file contains Go translations of the Rust implementations in
// https://gist.github.com/david-a-perez/067a126edf72bbca9325adaa8e53769a#file-fastest_day6_part2-rs

func Original() int {
	var idx int
outer:
	for idx+13 < len(input) {
		var state int
		for v := range iter.Enum(iter.RevBytes(input[idx : idx+14])) {
			next := v.One
			char := v.Two

			bit := char % 32
			if state&(1<<bit) != 0 {
				idx += next + 1
				continue outer
			}
			state |= 1 << bit
		}
		return idx
	}
	return -1
}

func Fastest() int {
	var idx int
	for idx+14 <= len(input) {
		slice := input[idx : idx+14]
		var state uint32

		var pos int
		for pos = len(slice) - 1; pos >= 0; pos-- {
			bit := slice[pos] % 32
			state |= 1 << bit
			if state&(1<<bit) != 0 {
				break
			}
		}
		if pos < 0 {
			return idx
		}
		idx += pos + 1
	}
	return -1
}

func Benny() int {
	var filter uint32
	for _, c := range input[:14-1] {
		filter ^= 1 << (c % 32)
	}
	return iter.Position(iter.Windows(iter.Bytes(input), 14), func(w []byte) bool {
		first := w[0]
		last := w[len(w)-1]
		filter ^= 1 << (last % 32)
		res := bits.OnesCount32(filter) == 14
		filter ^= 1 << (first % 32)
		return res
	}) + 14
}
