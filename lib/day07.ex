defmodule Day07 do
  use Advent

  def parse(lines, result \\ [])
  def parse([], result), do: Enum.reverse(result)

  def parse([<<cards::binary-(8 * 5), " ", score::binary>> | lines], result) do
    cards = cards |> String.trim() |> String.to_charlist() |> Enum.map(&card_check/1)
    score = score |> String.trim() |> String.to_integer()

    parse(lines, [{cards, score} | result])
  end

  def rank(cards), do: cards |> Enum.sort() |> rank_check()

  defp rank_check([a, a, a, a, a]), do: 6
  defp rank_check([a, a, a, b, b]), do: 5
  defp rank_check([a, a, b, b, b]), do: 5
  defp rank_check([a, a, a, _, _]), do: 4
  defp rank_check([_, a, a, a, _]), do: 4
  defp rank_check([_, _, a, a, a]), do: 4
  defp rank_check([a, a, b, b, _]), do: 3
  defp rank_check([a, a, _, b, b]), do: 3
  defp rank_check([_, a, a, b, b]), do: 3
  defp rank_check([a, a, _, _, _]), do: 2
  defp rank_check([_, a, a, _, _]), do: 2
  defp rank_check([_, _, a, a, _]), do: 2
  defp rank_check([_, _, _, a, a]), do: 2
  defp rank_check([_, _, _, _, _]), do: 1

  def hand_sorter(c1, c2) do
    rank(c1) < rank(c2) || card_sort(c1, c2)
  end

  defp card_sort([], []), do: false

  defp card_sort([c1 | cards1], [c2 | cards2]) do
    cond do
      c1 < c2 -> true
      c1 > c2 -> false
      c1 == c2 -> card_sort(cards1, cards2)
    end
  end

  defp card_check(?A), do: 13
  defp card_check(?K), do: 12
  defp card_check(?Q), do: 11
  defp card_check(?J), do: 10
  defp card_check(?T), do: 9
  defp card_check(?9), do: 8
  defp card_check(?8), do: 7
  defp card_check(?7), do: 6
  defp card_check(?6), do: 5
  defp card_check(?5), do: 4
  defp card_check(?4), do: 3
  defp card_check(?3), do: 2
  defp card_check(?2), do: 1

  def part1(io) do
    io
    |> Enum.map(&String.trim/1)
    |> parse()
    |> Enum.sort(fn {c1, _}, {c2, _} -> hand_sorter(c1, c2) end)
    |> Enum.with_index()
    |> Enum.map(fn {{_, score}, i} -> score * (i + 1) end)
    |> Enum.sum()
    |> dbg()
  end

  def part2(io) do
  end
end
