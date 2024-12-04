#!/usr/bin/env elixir

defmodule Day04 do
  def part1(input) do
    board = parse(input)

    for {start, _} <- board, reduce: 0 do
      count ->
        ur = get(board, start, {1, -1}, 4) |> xmas?() |> to_int()
        r = get(board, start, {1, 0}, 4) |> xmas?() |> to_int()
        dr = get(board, start, {1, 1}, 4) |> xmas?() |> to_int()
        d = get(board, start, {0, 1}, 4) |> xmas?() |> to_int()
        count + ur + r + dr + d
    end
  end

  def part2(input) do
    :not_implemented
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Stream.with_index()
    |> Stream.flat_map(fn {line, y} ->
      String.split(line, "", trim: true)
      |> Stream.with_index()
      |> Stream.map(fn {c, x} -> {{x, y}, c} end)
    end)
    |> Map.new()
  end

  defp get(board, start, step, count, result \\ [])
  defp get(_board, _start, _step, 0, result), do: Enum.reverse(result)

  defp get(board, {x, y} = start, {sx, sy} = step, count, result),
    do: get(board, {x + sx, y + sy}, step, count - 1, [board[start] | result])

  defp xmas?(["X", "M", "A", "S"]), do: true
  defp xmas?(["S", "A", "M", "X"]), do: true
  defp xmas?(_), do: false

  defp to_int(true), do: 1
  defp to_int(false), do: 0
end

input = IO.read(:eof)
IO.puts("Part 1: #{Day04.part1(input)}")
IO.puts("Part 2: #{Day04.part2(input)}")
