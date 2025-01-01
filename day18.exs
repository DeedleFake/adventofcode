#!/usr/bin/env elixir

Mix.install([:heap])

defmodule Day18 do
  def part1(input) do
    # limit = 12
    # bounds = {6, 6}
    limit = 1024
    bounds = {70, 70}

    input
    |> parse()
    |> Stream.take(limit)
    |> MapSet.new()
    |> print_bytes(bounds)
    |> astar(bounds)
    |> Stream.uniq()
    |> Enum.count()
  end

  def part2(input) do
    :not_implemented
  end

  defp parse(input) do
    input
    |> String.splitter("\n", trim: true)
    |> Stream.map(fn line ->
      line
      |> String.splitter(",", trim: true)
      |> Enum.map(&String.to_integer/1)
      |> List.to_tuple()
    end)
    |> Enum.to_list()
  end

  defp astar(bytes, bounds) do
    queue = Heap.new() |> Heap.push({dist({0, 0}, bounds), [{0, 0}]})
    astar_loop(queue, MapSet.new(), bytes, bounds)
  end

  defp astar_loop(queue, visited, bytes, bounds) do
    case Heap.split(queue) do
      {nil, nil} ->
        :no_route

      {{_, [^bounds | path]}, _queue} ->
        Enum.reverse(path)

      {{d, [cur | _] = path}, queue} ->
        if cur in visited do
          astar_loop(queue, visited, bytes, bounds)
        else
          visited = MapSet.put(visited, cur)

          queue =
            neighbors(cur)
            |> Stream.reject(&(&1 in bytes))
            |> Stream.reject(&(&1 in visited))
            |> Stream.filter(&in_bounds?(&1, bounds))
            |> Stream.map(fn loc -> {d + 1 + dist(loc, bounds), [loc | path]} end)
            |> Enum.into(queue)

          astar_loop(queue, visited, bytes, bounds)
        end
    end
  end

  defp dist({x1, y1}, {x2, y2}) do
    abs(x1 - x2) + abs(y1 - y2)
  end

  defp neighbors({x, y}) do
    [
      {x + 1, y},
      {x - 1, y},
      {x, y + 1},
      {x, y - 1}
    ]
  end

  defp in_bounds?({x, y}, {w, h}) do
    x in 0..w and y in 0..h
  end

  defp print_bytes(bytes, {w, h}) do
    for y <- 0..h do
      for x <- 0..w do
        if {x, y} in bytes do
          IO.write("#")
        else
          IO.write(".")
        end
      end

      IO.write("\n")
    end

    bytes
  end
end

input = IO.read(:eof)
IO.puts("Part 1: #{Day18.part1(input)}")
IO.puts("Part 2: #{Day18.part2(input)}")
