#!/usr/bin/env elixir

defmodule Day07 do
  import Bitwise
  import Integer, only: [is_even: 1, is_odd: 1]

  def part1(input) do
    input
    |> parse()
    |> Stream.filter(&valid?/1)
    |> Stream.map(&elem(&1, 0))
    |> Enum.sum()
  end

  def part2(input) do
    :not_implemented
  end

  defp parse(input) do
    input
    |> String.splitter("\n", trim: true)
    |> Stream.map(&String.split(&1, ":", trim: true))
    |> Enum.map(fn [result, terms] ->
      result = String.to_integer(result)
      terms = terms |> String.splitter(" ", trim: true) |> Enum.map(&String.to_integer/1)
      {result, terms}
    end)
  end

  defp valid?({result, terms}, mult \\ 0) do
    cond do
      mult >= 1 <<< (length(terms) - 1) -> false
      calc(terms, mult) == result -> true
      true -> valid?({result, terms}, mult + 1)
    end
  end

  defp calc([result], _mult), do: result

  defp calc([t1, t2 | terms], mult) when is_even(mult),
    do: calc([t1 + t2 | terms], mult >>> 1)

  defp calc([t1, t2 | terms], mult) when is_odd(mult),
    do: calc([t1 * t2 | terms], mult >>> 1)
end

input = IO.read(:eof)
IO.puts("Part 1: #{Day07.part1(input)}")
IO.puts("Part 2: #{Day07.part2(input)}")
