#!/usr/bin/env elixir

defmodule Day19 do
  def part1(input) do
    {towels, designs} = parse(input)
    designs |> Enum.count(&possible?(&1, towels))
  end

  def part2(input) do
    :not_implemented
  end

  defp parse(input) do
    [towels, designs] = input |> String.split("\n\n", trim: true)

    towels =
      towels |> String.splitter(",", trim: true) |> Stream.map(&String.trim/1) |> Enum.to_list()

    designs = designs |> String.split("\n", trim: true)

    {towels, designs}
  end

  defp possible?("", _towels), do: true

  defp possible?(design, towels) do
    towels
    |> Enum.any?(fn towel ->
      case design do
        ^towel <> next -> possible?(next, towels)
        _ -> false
      end
    end)
  end
end

input = IO.read(:eof)
IO.puts("Part 1: #{Day19.part1(input)}")
IO.puts("Part 2: #{Day19.part2(input)}")
