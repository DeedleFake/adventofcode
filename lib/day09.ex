defmodule Day09 do
  use Advent

  def next_num(subs) do
    for sub <- subs |> Stream.drop(1), reduce: 0 do
      prev -> List.last(sub) + prev
    end
  end

  def gen_subs(sequence) when not is_list(hd(sequence)), do: gen_subs([sequence])

  def gen_subs([bottom | sequences]) do
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
      String.trim(line) |> parse_nums() |> gen_subs() |> next_num()
    end
    |> Enum.sum()
  end

  def part2(io) do
  end
end
