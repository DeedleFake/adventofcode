defmodule Advent do
  defmacro __using__(_opts) do
    module = List.last(Module.split(__CALLER__.module))

    quote do
      def part1() do
        unquote(:part1)(
          IO.stream(File.open!(unquote("tmp/#{String.downcase(module)}_input.txt")), :line)
        )
      end

      def part2() do
        unquote(:part2)(
          IO.stream(File.open!(unquote("tmp/#{String.downcase(module)}_input.txt")), :line)
        )
      end
    end
  end
end
