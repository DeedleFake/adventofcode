#!/usr/bin/env elixir

Mix.install([:memoize])

defmodule Day11 do
  use Memoize

  import Integer, only: [is_even: 1]

  def part1(input) do
    parse(input)
    |> Stream.map(&evolve(&1, 25))
    |> Enum.sum()
  end

  def part2(input) do
    parse(input)
    |> Stream.map(&evolve(&1, 75))
    |> Enum.sum()
  end

  defp parse(input) do
    input
    |> String.split(~r/\s+/, trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  defmemop(evolve(_stone, 0), do: 1)
  defmemop(evolve(0, iter), do: evolve(1, iter - 1))

  defmemop evolve(stone, iter) do
    len = floor(:math.log10(stone) + 1)

    if is_even(len) do
      {left, right} =
        stone |> Integer.digits() |> Enum.split(div(len, 2))

      evolve(Integer.undigits(left), iter - 1) + evolve(Integer.undigits(right), iter - 1)
    else
      evolve(stone * 2024, iter - 1)
    end
  end
end

input = IO.read(:eof)
IO.puts("Part 1: #{Day11.part1(input)}")
IO.puts("Part 2: #{Day11.part2(input)}")
