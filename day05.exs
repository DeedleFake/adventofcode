#!/usr/bin/env elixir

defmodule Day05 do
  def part1(input) do
    {rules, printings} = input |> parse()

    for printing <- printings, valid?(printing, rules), reduce: 0 do
      total ->
        i = floor(length(printing) / 2)
        total + Enum.at(printing, i)
    end
  end

  def part2(input) do
    :not_implemented
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

  defp valid?([], rules), do: true

  defp valid?([page | printing], rules),
    do: page_valid?(page, printing, rules) and valid?(printing, rules)

  defp page_valid?(page, printing, rules) do
    printing
    |> Enum.all?(fn subsequent ->
      allowed = rules[subsequent]
      allowed && page in allowed
    end)
  end
end

input = IO.read(:eof)
IO.puts("Part 1: #{Day05.part1(input)}")
IO.puts("Part 2: #{Day05.part2(input)}")
