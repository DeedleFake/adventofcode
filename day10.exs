#!/usr/bin/env elixir

defmodule Day10 do
  def part1(input) do
    map = parse(input)

    for {start, h} <- map, h == 0, reduce: 0 do
      total -> total + MapSet.size(score(map, start))
    end
  end

  def part2(input) do
    map = parse(input)

    for {start, h} <- map, h == 0, reduce: 0 do
      total -> total + MapSet.size(rating(map, [start]))
    end
  end

  defp parse(input) do
    input
    |> String.splitter("\n", trim: true)
    |> Stream.with_index()
    |> Enum.flat_map(fn {line, y} ->
      line
      |> String.splitter("", trim: true)
      |> Stream.map(fn
        "." -> "-1"
        v -> v
      end)
      |> Stream.map(&String.to_integer/1)
      |> Stream.with_index()
      |> Stream.map(fn {h, x} -> {{x, y}, h} end)
    end)
    |> Map.new()
  end

  defp score(map, cur, peaks \\ MapSet.new())

  defp score(map, cur, peaks) when :erlang.map_get(cur, map) == 9, do: MapSet.put(peaks, cur)

  defp score(map, cur, peaks) do
    for next <- successors(map, cur), reduce: peaks do
      peaks -> score(map, next, peaks)
    end
  end

  defp rating(map, trail, trails \\ MapSet.new())

  defp rating(map, [cur | _] = trail, trails) when :erlang.map_get(cur, map) == 9,
    do: MapSet.put(trails, trail)

  defp rating(map, [cur | _] = trail, trails) do
    for next <- successors(map, cur), reduce: trails do
      trails -> rating(map, [next | trail], trails)
    end
  end

  defp successors(map, {x, y} = cur) do
    h = map[cur]

    [{x - 1, y}, {x + 1, y}, {x, y - 1}, {x, y + 1}]
    |> Stream.filter(fn next -> map[next] == h + 1 end)
  end
end

input = IO.read(:eof)
IO.puts("Part 1: #{Day10.part1(input)}")
IO.puts("Part 2: #{Day10.part2(input)}")
