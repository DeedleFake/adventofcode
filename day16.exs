#!/usr/bin/env elixir

Mix.install([:heap])

defmodule Day16 do
  def part1(input) do
    parse(input)
    |> shortest_route()
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

  defp shortest_route(maze) do
    queue = [{0, maze.start, :east}] |> Enum.into(Heap.new())
    shortest_route(maze, queue, MapSet.new())
  end

  defp shortest_route(maze, queue, visited) do
    case Heap.split(queue) do
      {{cost, loc, dir} = cur, queue} ->
        cond do
          loc == maze.goal ->
            cost

          {loc, dir} in visited ->
            shortest_route(maze, queue, visited)

          loc in maze.walls ->
            shortest_route(maze, queue, visited)

          true ->
            queue =
              next_moves(cur)
              |> Enum.into(queue)

            visited = MapSet.put(visited, {loc, dir})

            shortest_route(maze, queue, visited)
        end

      {nil, nil} ->
        :no_route_found
    end
  end

  defp next_moves({cost, loc, dir}) do
    [
      {cost + 1, move(dir, loc), dir},
      {cost + 1000, loc, turn(:left, dir)},
      {cost + 1000, loc, turn(:right, dir)}
    ]
  end

  defp move(:north, {x, y}), do: {x, y - 1}
  defp move(:south, {x, y}), do: {x, y + 1}
  defp move(:west, {x, y}), do: {x - 1, y}
  defp move(:east, {x, y}), do: {x + 1, y}

  defp turn(:left, :north), do: :west
  defp turn(:left, :west), do: :south
  defp turn(:left, :south), do: :east
  defp turn(:left, :east), do: :north
  defp turn(:right, :north), do: :east
  defp turn(:right, :west), do: :north
  defp turn(:right, :south), do: :west
  defp turn(:right, :east), do: :south
end

input = IO.read(:eof)
IO.puts("Part 1: #{Day16.part1(input)}")
IO.puts("Part 2: #{Day16.part2(input)}")
