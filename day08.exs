#!/usr/bin/env elixir

defmodule Day08 do
  defmodule City do
    @enforce_keys [:an, :bounds]
    defstruct @enforce_keys
  end

  def part1(input) do
    map = parse(input)

    antis =
      for {a1, f1} <- map.an,
          {a2, f2} <- map.an,
          f1 == f2,
          a1 != a2,
          into: MapSet.new() do
        shift(a1, a2)
      end
      |> MapSet.filter(&in_bounds?(&1, map.bounds))

    MapSet.size(antis)
  end

  def part2(input) do
    map = parse(input)

    antis =
      for {a1, f1} <- map.an,
          {a2, f2} <- map.an,
          f1 == f2,
          a1 != a2,
          reduce: MapSet.new() do
        antis -> add_antis(antis, a1, a2, map.bounds) |> MapSet.put(a1)
      end

    MapSet.size(antis)
  end

  defp parse(input) do
    lines = input |> String.splitter("\n", trim: true) |> Enum.map(&String.to_charlist/1)
    width = length(Enum.at(lines, 0))
    height = length(lines)

    an =
      lines
      |> Stream.with_index()
      |> Enum.flat_map(fn {line, y} ->
        line
        |> Stream.with_index()
        |> Stream.reject(&match?({?., _}, &1))
        |> Stream.map(fn {f, x} -> {{x, y}, f} end)
      end)

    %City{
      an: an,
      bounds: {width, height}
    }
  end

  defp in_bounds?({x, y}, {w, h}), do: x >= 0 and x < w and y >= 0 and y < h

  defp shift({x1, y1}, {x2, y2}), do: {x1 - (x2 - x1), y1 - (y2 - y1)}

  defp add_antis(antis, a1, a2, bounds) do
    next = shift(a1, a2)

    if in_bounds?(next, bounds) do
      antis = MapSet.put(antis, next)
      add_antis(antis, next, a1, bounds)
    else
      antis
    end
  end

  defp print_city(%City{} = city, antis \\ MapSet.new()) do
    {w, h} = city.bounds
    an = city.an |> Map.new()

    for y <- 0..h do
      for x <- 0..w do
        loc = {x, y}
        c = if loc in antis, do: "#", else: [Map.get(an, loc, ?.)]
        IO.write(c)
      end

      IO.write("\n")
    end

    :ok
  end
end

input = IO.read(:eof)
IO.puts("Part 1: #{Day08.part1(input)}")
IO.puts("Part 2: #{Day08.part2(input)}")
