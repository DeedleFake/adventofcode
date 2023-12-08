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

    def count_steps(input, start, target) do
      count_steps(input, %{
        cur: start |> Enum.sort(),
        target: target |> Enum.sort(),
        count: 0,
        dir: input.dir
      })
    end

    def count_steps(_input, state) when state.cur == state.target, do: state.count

    def count_steps(input, state = %{dir: []}),
      do: count_steps(input, %{state | dir: input.dir})

    def count_steps(input, state = %{dir: [step | dir]}) do
      new_state = %{
        state
        | dir: dir,
          cur: state.cur |> Stream.map(&next(input, &1, step)) |> Enum.sort(),
          count: state.count + 1
      }

      count_steps(input, new_state)
    end

    defp next(%{graph: graph}, cur, ?L), do: graph[cur] |> elem(0)
    defp next(%{graph: graph}, cur, ?R), do: graph[cur] |> elem(1)
  end

  def part1(io) do
    io
    |> Enum.map(&String.trim/1)
    |> Input.parse()
    |> Input.count_steps(["AAA"], ["ZZZ"])
  end

  def part2(io) do
    input =
      io
      |> Enum.map(&String.trim/1)
      |> Input.parse()

    starts = input.graph |> Map.keys() |> Enum.filter(&String.ends_with?(&1, "A"))
    targets = input.graph |> Map.keys() |> Enum.filter(&String.ends_with?(&1, "Z"))

    input |> Input.count_steps(starts, targets)
  end
end
