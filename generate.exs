#!/usr/bin/env elixir

defmodule Generate do
  def run() do
    [day] = System.argv()
    day = day |> String.to_integer() |> Integer.to_string() |> String.pad_leading(2, "0")

    path = "day#{day}.exs"
    File.write!(path, code(day), [:write, :exclusive])
    File.chmod!(path, 0o755)
  end

  defp code(day) do
    """
    #!/usr/bin/env elixir

    defmodule Day#{day} do
      def part1(input) do
        :not_implemented
      end

      def part2(input) do
        :not_implemented
      end
    end

    input = IO.read(:eof)
    IO.puts("Part 1: \#{Day#{day}.part1(input)}")
    IO.puts("Part 2: \#{Day#{day}.part2(input)}")
    """
  end
end

Generate.run()
