#!/usr/bin/env elixir

defmodule Day06 do
  def part1(input) do
    {guard, obstacles} = parse(input)
    dbg(guard)
    dbg(obstacles)
  end

  def part2(input) do
    :not_implemented
  end

  defp parse(input) do
    {[{guard, :guard}], obstacles} =
      input
      |> String.splitter("\n", trim: true)
      |> Stream.with_index()
      |> Stream.flat_map(fn {line, y} ->
        line
        |> String.splitter("")
        |> Stream.with_index()
        |> Stream.map(fn
          {"#", x} -> {{x, y}, :obstacle}
          {"^", x} -> {{x, y}, :guard}
          {_, _} -> nil
        end)
      end)
      |> Stream.reject(&is_nil/1)
      |> Enum.split_with(&match?({{_, _}, :guard}, &1))

    obstacles =
      obstacles
      |> Stream.map(fn {loc, :obstacle} -> loc end)
      |> MapSet.new()

    {{:up, guard}, obstacles}
  end
end

input = IO.read(:eof)
IO.puts("Part 1: #{Day06.part1(input)}")
IO.puts("Part 2: #{Day06.part2(input)}")
