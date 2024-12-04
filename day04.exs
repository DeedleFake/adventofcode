#!/usr/bin/env elixir

defmodule Day04 do
  def part1(input) do
    lines =
      input
      |> String.split("\n", trim: true)

    count(lines) + count(transpose(lines))
  end

  def part2(input) do
    :not_implemented
  end

  defp count(lines, result \\ 0)
  defp count([], result), do: result
  defp count([line | lines], result), do: count(lines, result + count_line(line))

  defp count_line(line, result \\ 0)
  defp count_line("", result), do: result
  defp count_line("XMAS" <> line, result), do: count_line("MAS" <> line, result + 1)
  defp count_line("SAMX" <> line, result), do: count_line("AMX" <> line, result + 1)
  defp count_line(<<_::8, line::binary>>, result), do: count_line(line, result)

  defp transpose(lines) do
    lines
    |> Stream.map(&String.split(&1, "", trim: true))
    |> Enum.zip_with(&List.to_string/1)
  end
end

input = IO.read(:eof)
IO.puts("Part 1: #{Day04.part1(input)}")
IO.puts("Part 2: #{Day04.part2(input)}")
