defmodule Day04 do
  use Advent

  defmodule Card do
    defstruct id: nil, winning: [], have: []
  end

  def parse_card("Card " <> card) do
    {id, ":" <> rem} = Integer.parse(String.trim_leading(card))
    {winning, "|" <> rem} = parse_numbers(rem)
    {have, ""} = parse_numbers(rem)

    %Card{
      id: id,
      winning: winning,
      have: have
    }
  end

  def num_matches(%{winning: winning, have: have}) do
    Enum.count(have, &(&1 in winning))
  end

  def count_with_copies(cards) do
    cards
    |> Stream.with_index()
    |> Enum.reduce(List.duplicate(1, Enum.count(cards)), fn {card, i}, acc ->
      case num_matches(card) do
        0 -> acc
        score -> add_copies(acc, i, (i + 1)..(i + score))
      end
    end)
    |> Enum.sum()
  end

  defp parse_numbers(str, nums \\ [])
  defp parse_numbers("", nums), do: {nums, ""}

  defp parse_numbers(str, nums) do
    case Integer.parse(String.trim_leading(str)) do
      {v, rem} -> parse_numbers(rem, [v | nums])
      :error -> {nums, String.trim_leading(str)}
    end
  end

  defp add_copies(nums, i, range) do
    Enum.reduce(range, nums, fn c, nums -> List.update_at(nums, c, &(&1 + Enum.at(nums, i))) end)
  end

  def part1(io) do
    io
    |> Stream.map(&String.trim/1)
    |> Stream.map(&Day04.parse_card/1)
    |> Stream.map(&Day04.num_matches/1)
    |> Stream.filter(&(&1 > 0))
    |> Stream.map(&Integer.pow(2, &1 - 1))
    |> Enum.sum()
  end

  def part2(io) do
    io
    |> Stream.map(&String.trim/1)
    |> Stream.map(&Day04.parse_card/1)
    |> Day04.count_with_copies()
  end
end
