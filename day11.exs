#!/usr/bin/env elixir

defmodule Day11 do
  import Integer, only: [is_even: 1]

  def part1(input) do
    stones = parse(input)

    stones =
      for _ <- 1..25//1, reduce: stones do
        stones -> stones |> Stream.flat_map(&evolve/1)
      end

    Enum.count(stones)
  end

  def part2(input) do
    stones = parse(input)

    stones =
      for _ <- 1..75//1, reduce: stones do
        stones -> stones |> Stream.flat_map(&evolve/1)
      end

    Enum.count(stones)
  end

  defp parse(input) do
    input
    |> String.split(~r/\s+/, trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  defp evolve(0), do: [1]

  defp evolve(stone) do
    len = :math.log10(stone + 1) |> ceil()
    evolve(stone, len)
  end

  defp evolve(stone, len) when is_even(len) do
    {left, right} =
      stone |> Integer.digits() |> Enum.split(div(len, 2))

    [Integer.undigits(left), Integer.undigits(right)]
  end

  defp evolve(stone, _len), do: [stone * 2024]
end

input = IO.read(:eof)
IO.puts("Part 1: #{Day11.part1(input)}")
IO.puts("Part 2: #{Day11.part2(input)}")
