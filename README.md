Advent of Code, 2023
====================

This branch contains solutions for the 2023 Advent of Code challenges. To run, first put the input file for a given day in `tmp/dayNN_input.txt`. For example, the input for day five should be put in `tmp/day05_input.txt`. Then, run `iex -S mix` and type `Day05.part1()` to, for example, run part 1 of day 5. If you'd like to provide alternate input, you can give the `part1()` and `part2()` functions a string argument to use in place of `input` in the filename. In other words, `Day05.part1("sample")` will use `tmp/day05_sample.txt` instead. Alternatively, you can also give either function an `Enum` that yields lines of input.
