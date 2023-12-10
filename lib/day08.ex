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

    def count_steps(input, start, target) when is_function(target) do
      count_steps(input, %{
        cur: start,
        target: target,
        count: 0,
        counts: start |> Enum.map(fn _ -> nil end),
        dir: input.dir
      })
    end

    def count_steps(input, start, [target]) do
      count_steps(input, start, fn cur -> cur == target end)
    end

    def count_steps(input, start, target), do: count_steps(input, start, [target])

    def count_steps(input, state = %{dir: []}),
      do: count_steps(input, %{state | dir: input.dir})

    def count_steps(input, state = %{dir: [step | dir]}) do
      counts =
        Stream.zip(state.counts, state.cur)
        |> Enum.map(fn
          {nil, cur} -> if state.target.(cur), do: state.count
          {count, _} -> count
        end)

      if Enum.all?(counts, &(&1 != nil)) do
        lcm(counts)
      else
        new_state = %{
          state
          | dir: dir,
            cur: state.cur |> Enum.map(&next(input, &1, step)),
            count: state.count + 1,
            counts: counts
        }

        count_steps(input, new_state)
      end
    end

    defp next(%{graph: graph}, cur, ?L), do: graph[cur] |> elem(0)
    defp next(%{graph: graph}, cur, ?R), do: graph[cur] |> elem(1)

    defp lcm(nums, result \\ 1)
    defp lcm([], result), do: result
    defp lcm([num], _result), do: num

    defp lcm([n1, n2 | nums], result) do
      val = n1 * n2 / Integer.gcd(n1, n2)
      lcm([round(val) | nums], result)
    end
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

    Input.count_steps(input, starts, fn cur -> String.ends_with?(cur, "Z") end)
  end
end
