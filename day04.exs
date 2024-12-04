#!/usr/bin/env elixir

defmodule Day04 do
  def part1(input) do
    board = parse(input)

    for {start, _} <- board, reduce: 0 do
      count ->
        found =
          [{1, -1}, {1, 0}, {1, 1}, {0, 1}]
          |> Stream.map(&get(board, start, &1, 4))
          |> Enum.count(&xmas?/1)

        count + found
    end
  end

  def part2(input) do
    board = parse(input)

    for {{cx, cy}, _} <- board, reduce: 0 do
      count ->
        left = get(board, {cx - 1, cy + 1}, {1, -1}, 3) |> mas?()
        right = get(board, {cx - 1, cy - 1}, {1, 1}, 3) |> mas?()
        if left and right, do: count + 1, else: count
    end
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

  defp mas?(["M", "A", "S"]), do: true
  defp mas?(["S", "A", "M"]), do: true
  defp mas?(_), do: false
end

input = IO.read(:eof)
IO.puts("Part 1: #{Day04.part1(input)}")
IO.puts("Part 2: #{Day04.part2(input)}")
