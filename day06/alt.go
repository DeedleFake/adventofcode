package main

import "adventofcode/internal/iter"

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
