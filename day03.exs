#!/usr/bin/env elixir

defmodule Day03 do
  def part1(input) do
    input
    |> parse()
    |> Stream.filter(&match?({"mul", _, _}, &1))
    |> Stream.map(&perform/1)
    |> Enum.sum()
  end

  def part2(input) do
    input
    |> parse()
    |> Enum.reduce({0, :do}, fn
      mode, {total, _} when mode in [:do, :dont] -> {total, mode}
      _, {total, :dont} -> {total, :dont}
      op, {total, :do} -> {total + perform(op), :do}
    end)
    |> elem(0)
  end

  @pattern ~r/don't\(\)|do\(\)|(mul)\(([0-9]+),([0-9]+)\)/

  defp parse(input) do
    @pattern
    |> Regex.scan(input)
    |> Stream.map(fn
      ["do()"] -> :do
      ["don't()"] -> :dont
      [_, op, a, b] -> {op, String.to_integer(a), String.to_integer(b)}
    end)
  end

  defp perform({"mul", a, b}), do: a * b
end

input = IO.read(:eof)
IO.puts("Part 1: #{Day03.part1(input)}")
IO.puts("Part 2: #{Day03.part2(input)}")
