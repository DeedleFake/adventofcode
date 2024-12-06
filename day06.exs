#!/usr/bin/env elixir

defmodule Day06 do
  defmodule Map do
    @enforce_keys [:guard, :obstacles, :bounds]
    defstruct @enforce_keys
  end

  def part1(input) do
    map = parse(input)
    patrol(map) |> Stream.uniq() |> Enum.count()
  end

  def part2(input) do
    :not_implemented
  end

  defp parse(input) do
    lines =
      input
      |> String.splitter("\n", trim: true)
      |> Enum.map(&String.split(&1, "", trim: true))

    {[{guard, :guard}], obstacles} =
      lines
      |> Stream.with_index()
      |> Stream.flat_map(fn {line, y} ->
        line
        |> Stream.with_index()
        |> Stream.map(fn
          {"#", x} -> {{x, y}, :obstacle}
          {"^", x} -> {{x, y}, :guard}
          {_, _} -> nil
        end)
      end)
      |> Stream.reject(&is_nil/1)
      |> Enum.split_with(&match?({{_, _}, :guard}, &1))

    obstacles =
      obstacles
      |> Stream.map(fn {loc, :obstacle} -> loc end)
      |> MapSet.new()

    width = length(lines)
    height = length(Enum.at(lines, 0))

    %Map{
      guard: [{:up, guard}],
      obstacles: obstacles,
      bounds: {width, height}
    }
  end

  defp patrol(map) do
    %Map{guard: [{_, loc} | _]} = map

    if in_bounds?(loc, map.bounds) do
      map
      |> advance()
      |> patrol()
    else
      tl(map.guard) |> Enum.reverse()
    end
  end

  defp advance(map) do
    [{_, loc} = guard | path] = map.guard
    next = next_loc(guard)

    if next in map.obstacles do
      advance(%Map{map | guard: [turn(guard) | path]})
    else
      %Map{map | guard: [move(guard, next), loc | path]}
    end
  end

  defp in_bounds?({x, y}, {w, h}) when x >= 0 and x < w and y >= 0 and y < h, do: true
  defp in_bounds?({_, _}, {_, _}), do: false

  defp next_loc({:up, {x, y}}), do: {x, y - 1}
  defp next_loc({:down, {x, y}}), do: {x, y + 1}
  defp next_loc({:left, {x, y}}), do: {x - 1, y}
  defp next_loc({:right, {x, y}}), do: {x + 1, y}

  defp move({dir, _}, loc), do: {dir, loc}

  defp turn({:up, loc}), do: {:right, loc}
  defp turn({:right, loc}), do: {:down, loc}
  defp turn({:down, loc}), do: {:left, loc}
  defp turn({:left, loc}), do: {:up, loc}
end

input = IO.read(:eof)
IO.puts("Part 1: #{Day06.part1(input)}")
IO.puts("Part 2: #{Day06.part2(input)}")
