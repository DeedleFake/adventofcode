#!/usr/bin/env elixir

defmodule Day12 do
  def part1(input) do
    garden = parse(input)

    find_regions(garden)
    |> Stream.map(&cost(&1, garden))
    |> Enum.sum()
  end

  def part2(input) do
    :not_implemented
  end

  defp parse(input) do
    input
    |> String.splitter("\n", trim: true)
    |> Stream.with_index()
    |> Stream.flat_map(fn {line, y} ->
      line
      |> String.splitter("", trim: true)
      |> Stream.with_index()
      |> Stream.map(fn {plant, x} -> {{x, y}, plant} end)
    end)
    |> Map.new()
  end

  defp find_regions(garden) do
    for {loc, plant} <- garden, reduce: [] do
      regions ->
        already? = regions |> Enum.any?(&(loc in &1))

        if already? do
          regions
        else
          [scan_region(garden, loc, plant) | regions]
        end
    end
  end

  defp scan_region(garden, loc, plant, region \\ MapSet.new()) do
    cond do
      garden[loc] != plant ->
        region

      loc in region ->
        region

      true ->
        region = MapSet.put(region, loc)
        Enum.reduce(neighbors(loc), region, &scan_region(garden, &1, plant, &2))
    end
  end

  defp neighbors({x, y}) do
    [
      {x - 1, y},
      {x + 1, y},
      {x, y - 1},
      {x, y + 1}
    ]
  end

  defp cost(region, garden), do: MapSet.size(region) * perimeter(region, garden)

  defp perimeter(region, garden) do
    region
    |> Stream.flat_map(fn loc ->
      loc
      |> neighbors()
      |> Stream.filter(&(garden[&1] != garden[loc]))
    end)
    |> Enum.count()
  end
end

input = IO.read(:eof)
IO.puts("Part 1: #{Day12.part1(input)}")
IO.puts("Part 2: #{Day12.part2(input)}")
