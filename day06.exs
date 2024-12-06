#!/usr/bin/env elixir

defmodule Day06 do
  defmodule Map do
    @enforce_keys [:guard, :obstacles, :bounds]
    defstruct @enforce_keys
  end

  def part1(input) do
    map = parse(input)
    patrol(map) |> Stream.uniq_by(&elem(&1, 1)) |> Enum.count()
  end

  def part2(input) do
    %Map{guard: {_, start}} = map = parse(input)
    path = patrol(map) |> Stream.uniq_by(&elem(&1, 1))

    for {_, loc} <- path, loc != start, reduce: 0 do
      total ->
        map = %Map{map | obstacles: MapSet.put(map.obstacles, loc)}
        if loops?(map), do: total + 1, else: total
    end
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
      guard: {:up, guard},
      obstacles: obstacles,
      bounds: {width, height}
    }
  end

  defp patrol({map, path}) do
    %Map{guard: {_, loc}} = map

    if in_bounds?(loc, map.bounds) do
      {map, path}
      |> advance()
      |> patrol()
    else
      tl(path) |> Enum.reverse()
    end
  end

  defp patrol(%Map{} = map), do: patrol({map, [map.guard]})

  defp loops?({map, path}) do
    %Map{guard: {_, loc}} = map

    if in_bounds?(loc, map.bounds) do
      if map.guard in tl(path) do
        true
      else
        {map, path}
        |> advance()
        |> loops?()
      end
    else
      false
    end
  end

  defp loops?(%Map{} = map), do: loops?({map, [map.guard]})

  defp advance({map, path}) do
    next = next_loc(map.guard)

    if next in map.obstacles do
      guard = turn(map.guard)
      advance({%Map{map | guard: guard}, [guard | path]})
    else
      guard = move(map.guard, next)
      {%Map{map | guard: guard}, [guard | path]}
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
