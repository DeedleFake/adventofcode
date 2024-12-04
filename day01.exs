#!/usr/bin/env elixir

defmodule Day01 do
  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Stream.map(&String.split(&1, " ", trim: true))
    |> Stream.map(fn [s1, s2] -> {String.to_integer(s1), String.to_integer(s2)} end)
    |> Enum.unzip()
  end

  def part1(input) do
    {left, right} = input |> parse()
    left = Enum.sort(left)
    right = Enum.sort(right)

    Stream.zip(left, right)
    |> Stream.map(fn {left, right} -> abs(left - right) end)
    |> Enum.sum()
  end

  def part2(input) do
    {left, right} = input |> parse()
    rightfreq = Enum.frequencies(right)

    left
    |> Stream.map(fn v -> v * Map.get(rightfreq, v, 0) end)
    |> Enum.sum()
  end
end

input = IO.read(:eof)
IO.puts("Part 1: #{Day01.part1(input)}")
IO.puts("Part 2: #{Day01.part2(input)}")
