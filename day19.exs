#!/usr/bin/env elixir

Mix.install([:memoize])

defmodule Day19 do
  use Memoize

  def part1(input) do
    {towels, designs} = parse(input)
    designs |> Enum.count(&possible?(&1, towels))
  end

  def part2(input) do
    {towels, designs} = parse(input)
    designs |> Enum.sum_by(&arrangements(&1, towels))
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

  defmemop(arrangements("", _towels), do: 1)

  defmemop arrangements(design, towels) do
    towels
    |> Enum.sum_by(fn towel ->
      case design do
        ^towel <> next -> arrangements(next, towels)
        _ -> 0
      end
    end)
  end
end

input = IO.read(:eof)
IO.puts("Part 1: #{Day19.part1(input)}")
IO.puts("Part 2: #{Day19.part2(input)}")
