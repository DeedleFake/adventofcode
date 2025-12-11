defmodule Day02 do
  def part1() do
    result =
      for range <- input(), id <- range, invalid?(id), reduce: 0 do
        total -> total + id
      end

    IO.puts(result)
  end

  defp input() do
    IO.read(:eof)
    |> String.trim()
    |> String.splitter(",")
    |> Stream.map(fn str -> String.split(str, "-", parts: 2) end)
    |> Stream.map(fn [from, to] -> String.to_integer(from)..String.to_integer(to)//1 end)
    |> Enum.to_list()
  end

  defp invalid?(id) do
    str = Integer.to_string(id)
    h = div(byte_size(str), 2)
    p1 = binary_slice(str, 0..(h - 1)//1)
    p2 = binary_slice(str, h..-1//1)
    p1 == p2
  end
end

Day02.part1()
