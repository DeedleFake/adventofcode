#!/usr/bin/env elixir

defmodule Day15 do
  def part1(input) do
    {state, dirs} = parse(input)
    state = Enum.reduce(dirs, state, &move_robot(&1, &2))

    state.boxes
    |> Stream.map(&gps/1)
    |> Enum.sum()
  end

  def part2(input) do
    :not_implemented
  end

  defp parse(input) do
    [state, dirs] = String.split(input, "\n\n", trim: true)

    {parse_state(state), parse_dirs(dirs)}
  end

  defp parse_state(input) do
    state =
      input
      |> String.splitter("\n", trim: true)
      |> Stream.with_index()
      |> Stream.flat_map(fn {line, y} ->
        line
        |> String.splitter("", trim: true)
        |> Stream.with_index()
        |> Stream.reject(&match?({".", _}, &1))
        |> Stream.map(fn {type, x} -> {type, {x, y}} end)
      end)
      |> Enum.group_by(&elem(&1, 0), &elem(&1, 1))

    [robot] = state["@"]

    %{
      robot: robot,
      walls: state["#"] |> MapSet.new(),
      boxes: state["O"] |> Stream.map(fn box -> [box] end) |> MapSet.new()
    }
  end

  defp parse_dirs(input) do
    input
    |> String.splitter("", trim: true)
    |> Stream.reject(&(&1 =~ ~r/\s/))
    |> Stream.map(fn
      "<" -> :left
      ">" -> :right
      "^" -> :up
      "v" -> :down
    end)
  end

  defp move_robot(dir, state) do
    moved = move(dir, state.robot)

    case shove(dir, state, [moved]) do
      {:moved, state} -> put_in(state.robot, moved)
      :blocked -> state
    end
  end

  defp shove(dir, state, box) do
    if Enum.any?(box, &(&1 in state.walls)) do
      :blocked
    else
      state.boxes
      |> Stream.filter(&collides?(box, &1))
      |> Enum.reduce_while({:moved, state}, fn collided, {:moved, new_state} ->
        moved = Enum.map(collided, &move(dir, &1))

        case shove(dir, new_state, moved) do
          {:moved, new_state} ->
            new_state =
              update_in(new_state.boxes, fn boxes ->
                boxes
                |> MapSet.delete(collided)
                |> MapSet.put(moved)
              end)

            {:cont, {:moved, new_state}}

          :blocked ->
            {:halt, :blocked}
        end
      end)
    end
  end

  defp move(:left, {x, y}), do: {x - 1, y}
  defp move(:right, {x, y}), do: {x + 1, y}
  defp move(:up, {x, y}), do: {x, y - 1}
  defp move(:down, {x, y}), do: {x, y + 1}

  defp collides?(b1, b2), do: Enum.any?(b1, &(&1 in b2))

  defp gps([{x, y}]), do: 100 * y + x

  defp print_state(state) do
    {w, h} = Enum.max(state.walls)

    for y <- 0..h//1 do
      for x <- 0..w//1 do
        cond do
          {x, y} == state.robot -> IO.write("@")
          {x, y} in state.walls -> IO.write("#")
          [{x, y}] in state.boxes -> IO.write("O")
          true -> IO.write(".")
        end
      end

      IO.write("\n")
    end

    state
  end
end

input = IO.read(:eof)
IO.puts("Part 1: #{Day15.part1(input)}")
IO.puts("Part 2: #{Day15.part2(input)}")
