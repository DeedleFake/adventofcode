#!/usr/bin/env elixir

defmodule Day15 do
  def part1(input) do
    {state, dirs} = parse(input)
    state = Enum.reduce(dirs, state, &move_robot/2)

    state.obstacles
    |> Stream.filter(&match?({_, :box}, &1))
    |> Stream.map(fn {loc, _} -> gps(loc) end)
    |> Enum.sum()
  end

  def part2(input) do
    :not_implemented
  end

  defp parse(input) do
    [map, dirs] = String.split(input, "\n\n", trim: true)
    {robot, obstacles} = parse_map(map)

    {%{
       robot: robot,
       obstacles: obstacles
     }, parse_dirs(dirs)}
  end

  defp parse_map(input) do
    map =
      input
      |> String.splitter("\n", trim: true)
      |> Stream.with_index()
      |> Stream.flat_map(fn {line, y} ->
        line
        |> String.splitter("", trim: true)
        |> Stream.with_index()
        |> Stream.reject(&match?({".", _}, &1))
        |> Stream.map(fn
          {"#", x} -> {{x, y}, :wall}
          {"O", x} -> {{x, y}, :box}
          {"@", x} -> {{x, y}, :robot}
        end)
      end)
      |> Map.new()

    {robot, _} = map |> Enum.find(&match?({_, :robot}, &1))
    map = Map.delete(map, robot)

    {robot, map}
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
    movements(state.robot, dir)
    |> Stream.map(&{&1, state.obstacles[&1]})
    |> Enum.reduce_while([], fn
      {_, nil}, boxes -> {:halt, boxes}
      {_, :wall}, _ -> {:halt, :wall}
      {box, :box}, boxes -> {:cont, [box | boxes]}
    end)
    |> case do
      :wall ->
        state

      [] ->
        %{state | robot: move(state.robot, dir)}

      [box] ->
        state =
          update_in(state.obstacles, fn obstacles ->
            obstacles
            |> Map.delete(box)
            |> Map.put(move(box, dir), :box)
          end)

        %{state | robot: move(state.robot, dir)}

      [first | boxes] ->
        state =
          update_in(state.obstacles, fn obstacles ->
            last = List.last(boxes)

            obstacles
            |> Map.delete(last)
            |> Map.put(move(first, dir), :box)
          end)

        %{state | robot: move(state.robot, dir)}
    end
  end

  defp movements(start, dir) do
    Stream.iterate(move(start, dir), &move(&1, dir))
  end

  defp move({x, y}, :left), do: {x - 1, y}
  defp move({x, y}, :right), do: {x + 1, y}
  defp move({x, y}, :up), do: {x, y - 1}
  defp move({x, y}, :down), do: {x, y + 1}

  defp gps({x, y}), do: 100 * y + x

  defp print_state(state) do
    {w, h} =
      state.obstacles
      |> Stream.map(&elem(&1, 0))
      |> Enum.max()

    for y <- 0..h//1 do
      for x <- 0..w//1 do
        case state.obstacles[{x, y}] do
          _ when {x, y} == state.robot -> IO.write("@")
          :wall -> IO.write("#")
          :box -> IO.write("O")
          nil -> IO.write(".")
        end
      end

      IO.write("\n")
    end

    :ok
  end
end

input = IO.read(:eof)
IO.puts("Part 1: #{Day15.part1(input)}")
IO.puts("Part 2: #{Day15.part2(input)}")
