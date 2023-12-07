defmodule Day07 do
  use Advent

  def parse(lines, result \\ [])
  def parse([], result), do: Enum.reverse(result)

  def parse([<<cards::binary-(8 * 5), " ", score::binary>> | lines], result) do
    cards = cards |> String.trim() |> String.to_charlist() |> Enum.map(&card_value/1)
    score = score |> String.trim() |> String.to_integer()

    parse(lines, [{cards, score} | result])
  end

  def rank(cards), do: cards |> Enum.sort() |> rank_value()

  defp rank_value([a, a, a, a, a]), do: 7
  defp rank_value([a, a, a, a, _]), do: 6
  defp rank_value([_, a, a, a, a]), do: 6
  defp rank_value([a, a, a, b, b]), do: 5
  defp rank_value([a, a, b, b, b]), do: 5
  defp rank_value([a, a, a, _, _]), do: 4
  defp rank_value([_, a, a, a, _]), do: 4
  defp rank_value([_, _, a, a, a]), do: 4
  defp rank_value([a, a, b, b, _]), do: 3
  defp rank_value([a, a, _, b, b]), do: 3
  defp rank_value([_, a, a, b, b]), do: 3
  defp rank_value([a, a, _, _, _]), do: 2
  defp rank_value([_, a, a, _, _]), do: 2
  defp rank_value([_, _, a, a, _]), do: 2
  defp rank_value([_, _, _, a, a]), do: 2
  defp rank_value([_, _, _, _, _]), do: 1

  def hand_sorter(c1, c2) do
    r1 = rank(c1)
    r2 = rank(c2)

    cond do
      r1 < r2 -> true
      r1 > r2 -> false
      r1 == r2 -> c1 < c2
    end
  end

  defp card_value(?A), do: 13
  defp card_value(?K), do: 12
  defp card_value(?Q), do: 11
  defp card_value(?J), do: 10
  defp card_value(?T), do: 9
  defp card_value(?9), do: 8
  defp card_value(?8), do: 7
  defp card_value(?7), do: 6
  defp card_value(?6), do: 5
  defp card_value(?5), do: 4
  defp card_value(?4), do: 3
  defp card_value(?3), do: 2
  defp card_value(?2), do: 1

  def part1(io) do
    io
    |> Enum.map(&String.trim/1)
    |> parse()
    |> Enum.sort(fn {c1, _}, {c2, _} -> hand_sorter(c1, c2) end)
    |> Stream.with_index()
    |> Stream.map(fn {{_, score}, i} -> score * (i + 1) end)
    |> Enum.sum()
  end

  def part2(io) do
  end
end
