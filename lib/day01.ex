defmodule Day01 do
  use Advent

  def line(str) do
    {left, right} = digits(str)
    left <> right
  end

  defp digits(_, _ \\ {"0", "0"})
  defp digits(<<>>, lr), do: lr
  defp digits(<<c, rem::binary>>, lr) when c in ?1..?9, do: digits(rem, combine(<<c>>, lr))
  defp digits(<<"one", rem::binary>>, lr), do: digits("e" <> rem, combine("1", lr))
  defp digits(<<"two", rem::binary>>, lr), do: digits("o" <> rem, combine("2", lr))
  defp digits(<<"three", rem::binary>>, lr), do: digits("e" <> rem, combine("3", lr))
  defp digits(<<"four", rem::binary>>, lr), do: digits(rem, combine("4", lr))
  defp digits(<<"five", rem::binary>>, lr), do: digits("e" <> rem, combine("5", lr))
  defp digits(<<"six", rem::binary>>, lr), do: digits(rem, combine("6", lr))
  defp digits(<<"seven", rem::binary>>, lr), do: digits("n" <> rem, combine("7", lr))
  defp digits(<<"eight", rem::binary>>, lr), do: digits("t" <> rem, combine("8", lr))
  defp digits(<<"nine", rem::binary>>, lr), do: digits("e" <> rem, combine("9", lr))
  defp digits(<<_, rem::binary>>, lr), do: digits(rem, lr)

  defp combine(new, {"0", "0"}), do: {new, new}
  defp combine(new, {left, _}), do: {left, new}

  def part1(_io) do
  end

  def part2(io) do
    io
    |> Stream.map(&String.trim(&1))
    |> Stream.map(&Day01.line(&1))
    |> Stream.map(&String.to_integer(&1))
    |> Enum.sum()
  end
end
