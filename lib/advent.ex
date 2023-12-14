defmodule Advent do
  defmacro __using__(_opts) do
    module = List.last(Module.split(__CALLER__.module))

    quote do
      import unquote(__MODULE__)

      def part1(suffix \\ "input")

      def part1(suffix) when is_binary(suffix) do
        unquote(:part1)(
          IO.stream(File.open!("tmp/#{String.downcase(unquote(module))}_#{suffix}.txt"), :line)
        )
      end

      def part2(suffix \\ "input")

      def part2(suffix) when is_binary(suffix) do
        unquote(:part2)(
          IO.stream(File.open!("tmp/#{String.downcase(unquote(module))}_#{suffix}.txt"), :line)
        )
      end
    end
  end

  def parse_nums(str, nums \\ [])
  def parse_nums("", nums), do: Enum.reverse(nums)
  def parse_nums(" " <> rem, nums), do: parse_nums(rem, nums)

  def parse_nums(str, nums) do
    case Integer.parse(str) do
      {v, rem} -> parse_nums(rem, [v | nums])
      :error -> nums
    end
  end

  def combinations(enum) do
    for {v1, i} <- enum |> Stream.with_index() |> Stream.drop(1),
        v2 <- enum |> Stream.take(i) do
      {v1, v2}
    end
  end
end
