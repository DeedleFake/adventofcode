#!/usr/bin/env elixir

defmodule Day03 do
  def part2(input) do
    input
    |> parse([{:do, []}])
    |> execute(0)
  end

  defp parse("", script), do: finish_block(script, nil) |> Enum.reverse()

  defp parse("do()" <> rest, script) do
    parse(rest, finish_block(script, :do))
  end

  defp parse("don't()" <> rest, script) do
    parse(rest, finish_block(script, :dont))
  end

  defp parse("mul(" <> rest, [{block_type, muls} = block | script]) do
    with {v1, rest} <- Integer.parse(rest),
         "," <> rest <- rest,
         {v2, rest} <- Integer.parse(rest),
         ")" <> rest <- rest do
      mul = {v1, v2}
      parse(rest, [{block_type, [mul | muls]} | script])
    else
      _ -> parse(rest, [block | script])
    end
  end

  defp parse(<<_::8, rest::binary>>, script), do: parse(rest, script)

  defp finish_block([{block_type, muls} | script], nil) do
    [{block_type, Enum.reverse(muls)} | script]
  end

  defp finish_block(script, next) do
    [{next, []} | finish_block(script, nil)]
  end

  defp execute([{:do, muls} | script], result) do
    result =
      for {a, b} <- muls, reduce: result do
        result -> result + a * b
      end

    execute(script, result)
  end

  defp execute([{:dont, _muls} | script], result), do: execute(script, result)

  defp execute([], result), do: result
end

input = IO.read(:eof)
IO.puts("Part 1: #{Day03.part1(input)}")
IO.puts("Part 2: #{Day03.part2(input)}")
