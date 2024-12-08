#!/usr/bin/env elixir

defmodule Day07 do
  import Integer, only: [is_even: 1, is_odd: 1]

  def part1(input) do
    input
    |> parse()
    |> Stream.filter(&valid?/1)
    |> Stream.map(&elem(&1, 0))
    |> Enum.sum()
  end

  def part2(input) do
    input
    |> parse()
    |> Stream.filter(&valid2?/1)
    |> Stream.map(&elem(&1, 0))
    |> Enum.sum()
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

  defp valid?({result, terms}, ops \\ 0) do
    cond do
      ops >= :math.pow(2, length(terms) - 1) -> false
      calc(terms, ops) == result -> true
      true -> valid?({result, terms}, ops + 1)
    end
  end

  defp calc([result], _ops), do: result

  defp calc([t1, t2 | terms], ops) when is_even(ops),
    do: calc([t1 + t2 | terms], next_ops(ops, 2))

  defp calc([t1, t2 | terms], ops) when is_odd(ops),
    do: calc([t1 * t2 | terms], next_ops(ops, 2))

  defp valid2?({result, terms}, ops \\ 0) do
    cond do
      ops >= :math.pow(3, length(terms) - 1) -> false
      calc2(terms, ops) == result -> true
      true -> valid2?({result, terms}, ops + 1)
    end
  end

  defp calc2([result], _ops), do: result

  defp calc2([t1, t2 | terms], ops) when rem(ops, 3) == 0,
    do: calc2([t1 + t2 | terms], next_ops(ops, 3))

  defp calc2([t1, t2 | terms], ops) when rem(ops, 3) == 1,
    do: calc2([t1 * t2 | terms], next_ops(ops, 3))

  defp calc2([t1, t2 | terms], ops) when rem(ops, 3) == 2 do
    t = Integer.undigits(Integer.digits(t1) ++ Integer.digits(t2))
    calc2([t | terms], next_ops(ops, 3))
  end

  defp next_ops(ops, n) when ops < n, do: 0
  defp next_ops(ops, n), do: div(ops, n)
end

input = IO.read(:eof)
IO.puts("Part 1: #{Day07.part1(input)}")
IO.puts("Part 2: #{Day07.part2(input)}")
