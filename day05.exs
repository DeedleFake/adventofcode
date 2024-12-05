#!/usr/bin/env elixir

defmodule Day05 do
  def part1(input) do
    {rules, printings} = input |> parse()

    for printing <- printings, valid?(printing, rules), reduce: 0 do
      total ->
        total + middle(printing)
    end
  end

  def part2(input) do
    {rules, printings} = input |> parse()

    for printing <- printings, !valid?(printing, rules), reduce: 0 do
      total ->
        printing = Enum.sort(printing, &less?(&1, &2, rules))
        total + middle(printing)
    end
  end

  defp parse(input) do
    [rules, printings] =
      input
      |> String.split("\n\n", trim: true)

    rules =
      for line <- String.split(rules, "\n", trim: true), reduce: %{} do
        rules ->
          [first, second] =
            line
            |> String.split("|")
            |> Enum.map(&String.to_integer/1)

          Map.update(rules, second, [first], fn r -> [first | r] end)
      end

    printings =
      for line <- String.split(printings, "\n", trim: true) do
        line
        |> String.split(",")
        |> Enum.map(&String.to_integer/1)
      end

    {rules, printings}
  end

  defp valid?([], _rules), do: true

  defp valid?([page | printing], rules),
    do: page_valid?(page, printing, rules) and valid?(printing, rules)

  defp page_valid?(page, printing, rules) do
    printing
    |> Enum.all?(&less?(page, &1, rules))
  end

  defp less?(p1, p2, rules) do
    allowed = Map.get(rules, p2, false)
    allowed && p1 in allowed
  end

  defp middle(v) do
    i = floor(length(v) / 2)
    Enum.at(v, i)
  end
end

input = IO.read(:eof)
IO.puts("Part 1: #{Day05.part1(input)}")
IO.puts("Part 2: #{Day05.part2(input)}")
