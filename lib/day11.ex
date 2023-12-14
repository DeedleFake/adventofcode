defmodule Day11 do
  use Advent

  def parse(input) do
    input
    |> Stream.with_index()
    |> Stream.flat_map(fn {line, y} ->
      String.to_charlist(line)
      |> Stream.with_index()
      |> Stream.filter(fn {c, _} -> c == ?# end)
      |> Stream.map(fn {_, x} -> {x, y} end)
    end)
    |> Enum.to_list()
  end

  def expand(map) do
    {{minx, miny}, {maxx, maxy}} = bounds(map)

    map =
      for split <- maxx..minx//-1,
          empty?(map, split, &elem(&1, 0)),
          reduce: map do
        map ->
          map
          |> Stream.map(fn
            {x, y} when x > split -> {x + 1, y}
            g -> g
          end)
      end
      |> Enum.to_list()

    map =
      for split <- maxy..miny//-1,
          empty?(map, split, &elem(&1, 1)),
          reduce: map do
        map ->
          map
          |> Stream.map(fn
            {x, y} when y > split -> {x, y + 1}
            g -> g
          end)
      end
      |> Enum.to_list()

    map
  end

  def distances(map) do
    for {{x1, y1}, {x2, y2}} <- map |> combinations() do
      abs(y2 - y1) + abs(x2 - x1)
    end
  end

  defp bounds(map) do
    {minx, maxx} = map |> Stream.map(&elem(&1, 0)) |> Enum.min_max()
    {miny, maxy} = map |> Stream.map(&elem(&1, 1)) |> Enum.min_max()
    {{minx, miny}, {maxx, maxy}}
  end

  defp empty?(map, num, check) do
    map |> Enum.all?(fn g -> check.(g) != num end)
  end

  def map_to_string(map) do
    {_, {x, y}} = bounds(map)

    for y <- 0..y do
      for x <- 0..x do
        if {x, y} in map do
          ?#
        else
          ?.
        end
      end
      |> List.to_string()
    end
    |> Enum.join("\n")
  end

  def part1(input) do
    input |> Stream.map(&String.trim/1) |> parse() |> expand() |> distances() |> Enum.sum()
  end

  def part2(input) do
  end
end
