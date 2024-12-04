#!/usr/bin/env elixir

defmodule Day02 do
  def part1(input) do
    input
    |> parse()
    |> Enum.count(&safe?/1)
  end

  def part2(input) do
    input
    |> parse()
    |> Enum.count(&full_safe?/1)
  end

  defp parse(input) do
    input
    |> String.splitter("\n", trim: true)
    |> Stream.map(&parse_line/1)
  end

  defp parse_line(line) do
    line
    |> String.splitter(" ", trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  defp safe?(record) do
    diffs = record |> Stream.chunk_every(2, 1, :discard) |> Enum.map(fn [a, b] -> b - a end)
    Enum.all?(diffs, &(&1 in 1..3//1)) or Enum.all?(diffs, &(&1 in -1..-3//-1))
  end

  defp full_safe?(record) do
    [record]
    |> Stream.concat(remove_levels(record))
    |> Enum.any?(&safe?/1)
  end

  defp remove_levels(record) do
    0..(length(record) - 1)//1
    |> Stream.map(&remove_level(record, &1))
  end

  defp remove_level(record, level) do
    record
    |> Stream.with_index()
    |> Stream.reject(fn {_, i} -> i == level end)
    |> Stream.map(fn {v, _} -> v end)
  end
end

input = IO.read(:eof)
IO.puts("Part 1: #{Day02.part1(input)}")
IO.puts("Part 2: #{Day02.part2(input)}")
