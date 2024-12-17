#!/usr/bin/env elixir

Mix.install([:heap])

defmodule Day16 do
  def part1(input) do
    maze = parse(input)
    costs = dijkstras(maze)
    costs[maze.goal]
  end

  def part2(input) do
    maze = parse(input)
    costs = dijkstras(maze)

    costs
    |> short_routes_tiles(maze.start, maze.goal)
    |> MapSet.size()
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

  defp dijkstras(maze) do
    dist = %{}

    queue =
      Heap.new()
      |> Heap.push({0, {maze.start, :east}})

    dijkstras(maze, queue, dist)
  end

  defp dijkstras(maze, queue, dist) do
    case Heap.split(queue) do
      {{cost, {loc, dir}}, queue} ->
        if cost < dist[loc] do
          dist = Map.put(dist, loc, cost)

          queue =
            next_moves({cost, {loc, dir}})
            |> Stream.reject(fn {_, {loc, _}} -> loc in maze.walls end)
            |> Stream.filter(fn {cost, {loc, _}} -> cost < dist[loc] end)
            |> Enum.into(queue)

          dijkstras(maze, queue, dist)
        else
          dijkstras(maze, queue, dist)
        end

      {nil, nil} ->
        dist
    end
  end

  defp short_routes_tiles(costs, start, target) do
    short_routes_tiles(costs, [[start]], target, MapSet.new([target]))
  end

  defp short_routes_tiles(_costs, [], _target, result), do: result

  defp short_routes_tiles(costs, [[{x, y} | prev] = path | next], target, result) do
    if still_valid?(path, costs) do
      if {x, y} in result do
        result = Enum.into(path, result)
        short_routes_tiles(costs, next, target, result)
      else
        next =
          [{x + 1, y}, {x - 1, y}, {x, y + 1}, {x, y - 1}]
          |> Stream.filter(fn loc -> costs[loc] <= costs[target] end)
          |> Stream.reject(fn loc -> loc in prev end)
          |> Stream.map(fn loc -> [loc | path] end)
          |> Enum.concat(next)

        short_routes_tiles(costs, next, target, result)
      end
    else
      short_routes_tiles(costs, next, target, result)
    end
  end

  defp next_moves({cost, {loc, dir}}) do
    left = turn(:left, dir)
    right = turn(:right, dir)

    [
      {cost + 1, {move(dir, loc), dir}},
      {cost + 1001, {move(left, loc), left}},
      {cost + 1001, {move(right, loc), right}}
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

  defp still_valid?([a, b, c | _], costs) do
    cb = costs[b]
    costs[a] > cb or cb > costs[c]
  end

  defp still_valid?(_path, _costs), do: true

  defp print_costs(maze, costs, highlight \\ []) do
    {w, h} = Enum.max(maze.walls)

    for y <- 0..(h - 1) do
      for x <- 0..(w - 1) do
        case costs[{x, y}] do
          nil ->
            IO.write("        ")

          cost ->
            if {x, y} in highlight do
              IO.write(IO.ANSI.yellow_background())
              IO.write(IO.ANSI.black())
            end

            IO.write("[" <> String.pad_leading("#{cost}", 6) <> "]")
            IO.write(IO.ANSI.reset())
        end
      end

      IO.write("\n")
    end

    :ok
  end
end

input = IO.read(:eof)
IO.puts("Part 1: #{Day16.part1(input)}")
IO.puts("Part 2: #{Day16.part2(input)}")
