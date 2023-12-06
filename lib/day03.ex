defmodule Day03 do
  use Advent

  defmodule Line do
    defstruct parts: [], symbols: []
  end

  defmodule Part do
    defstruct index: nil, number: nil
  end

  defmodule Symbol do
    defstruct index: nil, symbol: nil
  end

  def parse_line(str, i \\ 0, line \\ %Line{})
  def parse_line("", _i, line), do: line
  def parse_line(<<?., rem::binary>>, i, line), do: parse_line(rem, i + 1, line)

  def parse_line(<<c, rem::binary>>, i, line) when c in ?0..?9 do
    str = <<c>> <> rem

    case Integer.parse(str) do
      {v, rem} ->
        parse_line(
          rem,
          i + floor(:math.log10(v)) + 1,
          %Line{line | parts: line.parts ++ [%Part{index: i, number: Integer.to_string(v)}]}
        )

      :error ->
        raise("parse integer from #{str}")
    end
  end

  def parse_line(<<sym, rem::binary>>, i, line) do
    parse_line(
      rem,
      i + 1,
      %Line{line | symbols: line.symbols ++ [%Symbol{index: i, symbol: <<sym>>}]}
    )
  end

  def part_numbers([prev, cur, next]) do
    symbols = List.flatten([cur.symbols, prev.symbols, next.symbols]) |> Stream.map(& &1.index)

    cur.parts
    |> Stream.filter(fn part -> Enum.any?(symbols, &adjacent?(&1, [part])) end)
    |> Enum.map(&String.to_integer(&1.number))
  end

  def gear_numbers([prev, cur, next]) do
    parts = List.flatten([prev.parts, cur.parts, next.parts])

    cur.symbols
    |> Stream.filter(&(&1.symbol == "*"))
    |> Stream.map(&adjacent(&1.index, parts))
    |> Stream.filter(&(length(&1) == 2))
    |> Stream.map(&gear_number/1)
    |> Enum.to_list()
  end

  def adjacent(index, parts) do
    range = (index - 1)..(index + 1)

    parts
    |> Enum.filter(fn part ->
      prange = part.index..(part.index + String.length(part.number) - 1)
      !Range.disjoint?(range, prange)
    end)
  end

  def adjacent?(index, parts) do
    !Enum.empty?(adjacent(index, parts))
  end

  def gear_number([p1, p2]) do
    String.to_integer(p1.number) * String.to_integer(p2.number)
  end

  def part1(io) do
    io
    |> Stream.map(&String.trim/1)
    |> Stream.map(&Day03.parse_line/1)
    |> (&Stream.concat([struct(Day03.Line)], &1)).()
    |> Stream.chunk_every(3, 1, Stream.cycle([struct(Day03.Line)]))
    |> Stream.map(&Day03.part_numbers/1)
    |> Stream.concat()
    |> Enum.sum()
  end

  def part2(io) do
    io
    |> Stream.map(&String.trim/1)
    |> Stream.map(&Day03.parse_line/1)
    |> (&Stream.concat([struct(Day03.Line)], &1)).()
    |> Stream.chunk_every(3, 1, Stream.cycle([struct(Day03.Line)]))
    |> Stream.map(&Day03.gear_numbers/1)
    |> Stream.concat()
    |> Enum.sum()
  end
end
