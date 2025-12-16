defmodule Day02 do
  def part1(input) do
    result =
      for range <- parse(input), id <- range, invalid?(id), reduce: 0 do
        total -> total + id
      end

    IO.puts(result)
  end

  def part2(input) do
    result =
      for range <- parse(input), id <- range, invalid2?(id), reduce: 0 do
        total -> total + id
      end

    IO.puts(result)
  end

  defp parse(input) do
    input
    |> String.replace(~r/\s/, "")
    |> String.splitter(",")
    |> Stream.map(fn str -> String.split(str, "-", parts: 2) end)
    |> Stream.map(fn [from, to] -> String.to_integer(from)..String.to_integer(to)//1 end)
    |> Enum.to_list()
  end

  defp invalid?(id) do
    str = Integer.to_string(id)
    str =~ ~r/^(.{2,})\1$/
  end

  defp invalid2?(id) do
    str = Integer.to_string(id)
    str =~ ~r/^(.+)\1+$/
  end
end

input = IO.read(:eof)
Day02.part1(input)
Day02.part2(input)
