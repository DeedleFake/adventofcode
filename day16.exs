#!/usr/bin/env elixir

Mix.install([:heap])

defmodule Day16 do
  def part1(input) do
    maze = parse(input)
    dbg(maze)
  end

  def part2(input) do
    :not_implemented
  end

  defp parse(input) do
    tiles =
      input
      |> String.splitter("\n", trim: true)
      |> Stream.with_index()
      |> Stream.flat_map(fn {line, y} ->
        line
        |> String.splitter("", trim: true)
        |> Stream.with_index()
        |> Stream.map(fn {c, x} -> {{x, y}, c} end)
      end)
      |> Stream.reject(&match?({_, "."}, &1))
      |> Enum.group_by(&elem(&1, 1), &elem(&1, 0))

    [start] = tiles["S"]
    [goal] = tiles["E"]
    walls = MapSet.new(tiles["#"])

    %{
      start: start,
      goal: goal,
      walls: walls
    }
  end

  defp shortest_route(maze), do: shortest_route_search(maze, maze.start, [])

  defp shortest_route_search(maze, cur, path, queue \\ :queue.new())

  defp shortest_route_search(maze, cur, path, _queue) when cur == maze.goal, do: path

  defp shortest_route_search(maze, cur, path, queue) do
    # TODO: Stuff.
  end
end

input = IO.read(:eof)
IO.puts("Part 1: #{Day16.part1(input)}")
IO.puts("Part 2: #{Day16.part2(input)}")
