defmodule Day06 do
  use Advent

  defmodule Race do
    defstruct time: nil, dist: nil

    def new({time, dist}), do: %Race{time: time, dist: dist}

    def victories(race) do
      mid = ceil(race.time / 2)
      adjust = rem(race.time, 2)

      result =
        mid..(race.time - 1)//1
        |> Stream.take_while(&(&1 * (race.time - &1) > race.dist))
        |> Enum.count()

      result * 2 - (1 - adjust)
    end
  end

  def parse(lines, result \\ %{time: [], dist: []})
  def parse([], %{time: time, dist: dist}), do: Stream.zip(time, dist) |> Enum.map(&Race.new/1)

  def parse(["Time:" <> line | lines], result),
    do: parse(lines, %{result | time: Advent.parse_nums(line, result.time)})

  def parse(["Distance:" <> line | lines], result),
    do: parse(lines, %{result | dist: Advent.parse_nums(line, result.dist)})

  def part1(io) do
    io
    |> Enum.map(&String.trim/1)
    |> parse()
    |> Stream.map(&Race.victories/1)
    |> Enum.product()
  end

  def part2(io) do
  end
end
