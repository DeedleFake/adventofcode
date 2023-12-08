defmodule Day08 do
  use Advent

  defmodule Input do
    defstruct dir: [], graph: %{}

    def parse(lines, result \\ %__MODULE__{})
    def parse([], result), do: result
    def parse(["" | lines], result), do: parse(lines, result)

    def parse(
          [<<name::8*3-binary, " = (", left::8*3-binary, ", ", right::8*3-binary, ")">> | lines],
          result
        ),
        do:
          parse(lines, %__MODULE__{result | graph: result.graph |> Map.put(name, {left, right})})

    def parse([<<start::8, rest::binary>> | lines], result) when start in [?L, ?R],
      do: parse(lines, %__MODULE__{result | dir: <<start, rest::binary>> |> String.to_charlist()})

    def count_steps(input, state \\ %{count: 0, cur: "AAA", target: "ZZZ", dir: []})
    def count_steps(_input, state) when state.cur == state.target, do: state.count

    def count_steps(input, state = %{dir: []}),
      do: input |> count_steps(%{state | dir: input.dir})

    def count_steps(input, state = %{dir: [step | dir]}),
      do:
        input
        |> count_steps(%{
          state
          | dir: dir,
            cur: next(input, state.cur, step),
            count: state.count + 1
        })

    defp next(%{graph: graph}, cur, ?L), do: graph[cur] |> elem(0)
    defp next(%{graph: graph}, cur, ?R), do: graph[cur] |> elem(1)
  end

  def part1(io) do
    io
    |> Enum.map(&String.trim/1)
    |> Input.parse()
    |> Input.count_steps()
  end

  def part2(io) do
  end
end
