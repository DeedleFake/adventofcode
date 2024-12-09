#!/usr/bin/env elixir

defmodule Day08 do
  defmodule City do
    @enforce_keys [:an, :bounds]
    defstruct @enforce_keys
  end

  def part1(input) do
    map = parse(input)

    antis =
      for {{x1, y1}, f1} <- map.an,
          {{x2, y2}, f2} <- map.an,
          f1 == f2,
          {x1, y1} != {x2, y2},
          into: MapSet.new() do
        {x1 - (x2 - x1), y1 - (y2 - y1)}
      end
      |> MapSet.filter(&in_bounds?(&1, map.bounds))

    MapSet.size(antis)
  end

  def part2(input) do
    :not_implemented
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
end

input = IO.read(:eof)
IO.puts("Part 1: #{Day08.part1(input)}")
IO.puts("Part 2: #{Day08.part2(input)}")
