defmodule Day09 do
  use Advent

  def next_num(sequence) do
    subs = gen_subs([sequence])

    for sub <- subs |> Stream.drop(1), reduce: 0 do
      prev -> List.last(sub) + prev
    end
  end

  def prev_num(sequence) do
    subs = gen_subs([sequence])

    for sub <- subs |> Stream.drop(1), reduce: 0 do
      prev -> hd(sub) - prev
    end
  end

  defp gen_subs([bottom | sequences]) do
    if bottom |> Enum.all?(&(&1 == 0)) do
      [bottom | sequences]
    else
      gen_subs([diffs(bottom), bottom | sequences])
    end
  end

  defp diffs(sequence) do
    for [n1, n2] <- sequence |> Stream.chunk_every(2, 1) do
      n2 - n1
    end
  end

  def part1(io) do
    for line <- io do
      String.trim(line) |> parse_nums() |> next_num()
    end
    |> Enum.sum()
  end

  def part2(io) do
    for line <- io do
      String.trim(line) |> parse_nums() |> prev_num()
    end
    |> Enum.sum()
  end
end
