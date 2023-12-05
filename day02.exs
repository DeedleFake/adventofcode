#!/usr/bin/env elixir

defmodule Day02 do
  defmodule Line do
    defstruct red: 0, green: 0, blue: 0
  end

  def line(str) do
    [start, rem] = String.split(str, ":", trim: true, parts: 2)
    {parse_id(start), find_max(rem)}
  end

  def filter({_id, colors}) do
    colors.red <= 12 and
      colors.green <= 13 and
      colors.blue <= 14
  end

  def parse_id("Game " <> id) do
    String.to_integer(id)
  end

  def find_max(str) do
    enum =
      groups(str)
      |> Stream.map(fn {color, nums} -> {color, Enum.max(nums)} end)

    struct!(Line, enum)
  end

  def groups(str) do
    String.splitter(str, ";")
    |> Stream.flat_map(&parse_cubes/1)
    |> Enum.group_by(& &1.color, & &1.num)
  end

  def parse_cubes(str) do
    String.splitter(str, [",", ";"])
    |> Stream.map(&parse_cube/1)
  end

  def parse_cube(str) do
    [num, color] = String.split(str, " ", trim: true, parts: 2)
    %{color: String.to_atom(color), num: String.to_integer(num)}
  end
end

input = IO.stream() |> Enum.to_list()

# Part 1:
input
|> Stream.map(&String.trim/1)
|> Stream.map(&Day02.line/1)
|> Stream.filter(&Day02.filter/1)
|> Stream.map(&elem(&1, 0))
|> Enum.sum()
|> IO.puts()

# Part 2:
input
|> Stream.map(&String.trim/1)
|> Stream.map(&Day02.line/1)
|> Stream.map(&elem(&1, 1))
|> Stream.map(&Map.from_struct/1)
|> Stream.map(&Map.values/1)
|> Stream.map(&Enum.product/1)
|> Enum.sum()
|> IO.puts()
