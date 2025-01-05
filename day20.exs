#!/usr/bin/env elixir

defmodule Day20 do
  def part1(input) do
    input
    |> parse()
    |> path_distances()
    |> cheats()
    |> Stream.filter(&match?({_, _, saved} when saved >= 100, &1))
    |> Enum.count()
  end

  def part2(input) do
    input
    |> parse()
    |> path_distances()
    |> cheats(20)
    |> Stream.filter(&match?({_, _, saved} when saved >= 100, &1))
    |> Enum.count()
  end

  defp parse(input) do
    map =
      input
      |> String.splitter("\n", trim: true)
      |> Stream.with_index()
      |> Stream.flat_map(fn {line, y} ->
        line
        |> String.splitter("", trim: true)
        |> Stream.with_index()
        |> Stream.reject(&match?({"#", _}, &1))
        |> Stream.map(fn
          {"S", x} -> {:start, {x, y}}
          {"E", x} -> {:goal, {x, y}}
          {".", x} -> {:path, {x, y}}
        end)
      end)
      |> Enum.group_by(&elem(&1, 0), &elem(&1, 1))

    [start] = map.start
    [goal] = map.goal
    %{map | path: [start, goal | map.path] |> MapSet.new(), start: start, goal: goal}
  end

  defp path_distances(%{start: start, goal: goal, path: path}) do
    path_distances_loop(start, goal, path, 0, %{})
  end

  defp path_distances_loop(goal, goal, _path, dist, result), do: Map.put(result, goal, dist)

  defp path_distances_loop(cur, goal, path, dist, result) do
    result =
      result
      |> Map.put(cur, dist)

    [next] =
      neighbors(cur)
      |> Stream.filter(&(&1 in path))
      |> Stream.reject(&is_map_key(result, &1))
      |> Enum.to_list()

    path_distances_loop(next, goal, path, dist + 1, result)
  end

  defp neighbors({x, y}) do
    [
      {x + 1, y},
      {x - 1, y},
      {x, y + 1},
      {x, y - 1}
    ]
  end

  defp cheats(distances, max_len \\ 2) do
    distances
    |> Stream.flat_map(fn {from, dist} ->
      gen_cheats(from, max_len)
      |> Stream.filter(&match?({to, _} when is_map_key(distances, to), &1))
      |> Stream.map(fn {to, len} -> {from, to, distances[to] - dist - len} end)
    end)
  end

  defp gen_cheats({x, y}, max_len) do
    for len <- 2..max_len, dx <- 0..len do
      dy = len - dx

      [
        {x + dx, y + dy},
        {x - dx, y + dy},
        {x + dx, y - dy},
        {x - dx, y - dy}
      ]
      |> Stream.map(&{&1, len})
    end
    |> Stream.concat()
    |> Enum.group_by(&elem(&1, 0), &elem(&1, 1))
    |> Stream.map(fn {to, lens} -> {to, Enum.min(lens)} end)
  end
end

input = IO.read(:eof)
IO.puts("Part 1: #{Day20.part1(input)}")
IO.puts("Part 2: #{Day20.part2(input)}")
