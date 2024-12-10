#!/usr/bin/env elixir

defmodule Day09 do
  def part1(input) do
    layout = parse(input)

    free =
      layout
      |> Stream.with_index()
      |> Stream.filter(&match?({-1, _}, &1))
      |> Stream.map(&elem(&1, 1))

    data =
      layout
      |> Stream.with_index()
      |> Stream.reject(&match?({-1, _}, &1))
      |> Enum.reverse()

    new_layout =
      Stream.zip(data, free)
      |> Stream.take_while(fn {{_, from}, to} -> to < from end)
      |> Enum.reduce(to_counters(layout), fn {{d, from}, to}, layout ->
        :counters.put(layout, to, d)
        :counters.put(layout, from, -1)
        layout
      end)
      |> stream_counters()

    checksum(new_layout)
  end

  def part2(input) do
    :not_implemented
  end

  defp parse(input) do
    input
    |> String.trim()
    |> String.splitter("", trim: true)
    |> Stream.map(&String.to_integer/1)
    |> Enum.reduce({[], 0, :data}, fn
      n, {result, file, :data} -> {result ++ List.duplicate(file, n), file + 1, :free}
      n, {result, file, :free} -> {result ++ List.duplicate(-1, n), file, :data}
    end)
    |> elem(0)
  end

  defp checksum(data) do
    data
    |> Stream.filter(&(&1 >= 0))
    |> Stream.with_index()
    |> Stream.map(fn {d, i} -> d * i end)
    |> Enum.sum()
  end

  defp to_counters(nums) do
    counters = :counters.new(length(nums), [:write_concurrency])

    for {n, i} <- Stream.with_index(nums), reduce: counters do
      counters ->
        :counters.put(counters, i + 1, n)
        counters
    end
  end

  defp stream_counters(counters) do
    %{size: size} = :counters.info(counters)

    Stream.unfold(1, fn
      i when i > size -> nil
      i -> {:counters.get(counters, i), i + 1}
    end)
  end
end

input = IO.read(:eof)
IO.puts("Part 1: #{Day09.part1(input)}")
IO.puts("Part 2: #{Day09.part2(input)}")
