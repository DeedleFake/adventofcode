defmodule Day07 do
  use Advent

  def parse(lines, result \\ [])
  def parse([], result), do: Enum.reverse(result)

  def parse([<<hand::binary-(8 * 5), " ", score::binary>> | lines], result) do
    hand = hand |> String.trim() |> String.to_charlist() |> Enum.map(&card_value/1)
    score = score |> String.trim() |> String.to_integer()

    parse(lines, [{hand, score} | result])
  end

  def rank(hand), do: hand |> Enum.sort() |> rank_value()

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

  def compare_hands({c1, j1}, {c2, j2}) do
    r1 = rank(j1)
    r2 = rank(j2)

    cond do
      r1 < r2 -> true
      r1 > r2 -> false
      r1 == r2 -> c1 < c2
    end
  end

  def compare_hands(c1, c2), do: compare_hands({c1, c1}, {c2, c2})

  def card_value(?A), do: 13
  def card_value(?K), do: 12
  def card_value(?Q), do: 11
  def card_value(?J), do: 10
  def card_value(?T), do: 9
  def card_value(?9), do: 8
  def card_value(?8), do: 7
  def card_value(?7), do: 6
  def card_value(?6), do: 5
  def card_value(?5), do: 4
  def card_value(?4), do: 3
  def card_value(?3), do: 2
  def card_value(?2), do: 1

  def to_joker(10), do: 0
  def to_joker(c), do: c

  def apply_jokers(hand) do
    hand
    |> Stream.reject(&(&1 == 0))
    |> Stream.map(fn c ->
      hand
      |> Enum.map(fn
        0 -> c
        e -> e
      end)
    end)
    |> Enum.max(&(!compare_hands(&1, &2)), fn -> hand end)
  end

  defp hands_to_ranked_scores(hands) do
    hands
    |> Enum.sort(fn {c1, _}, {c2, _} -> compare_hands(c1, c2) end)
    |> Stream.with_index()
    |> Stream.map(fn {{_, score}, i} -> score * (i + 1) end)
  end

  def part1(io) do
    io
    |> Enum.map(&String.trim/1)
    |> parse()
    |> hands_to_ranked_scores()
    |> Enum.sum()
  end

  def part2(io) do
    io
    |> Enum.map(&String.trim/1)
    |> parse()
    |> Stream.map(fn {hand, score} -> {hand |> Enum.map(&to_joker/1), score} end)
    |> Stream.map(fn {hand, score} -> {{hand, apply_jokers(hand)}, score} end)
    |> hands_to_ranked_scores()
    |> Enum.sum()
  end
end
