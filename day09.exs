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
      |> Enum.reduce(layout, fn {{d, from}, to}, layout ->
        layout |> List.replace_at(to, d) |> List.replace_at(from, -1)
      end)

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
end

input = IO.read(:eof)
IO.puts("Part 1: #{Day09.part1(input)}")
IO.puts("Part 2: #{Day09.part2(input)}")
