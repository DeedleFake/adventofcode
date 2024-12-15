#!/usr/bin/env elixir

defmodule Day14 do
  defmodule Robot do
    @enforce_keys [:position, :velocity]
    defstruct @enforce_keys

    def parse(input) do
      %{"p" => position, "v" => velocity} =
        input
        |> String.split(~r/\s/, trim: true)
        |> Stream.map(&parse_mapping/1)
        |> Map.new()

      %__MODULE__{position: position, velocity: velocity}
    end

    defp parse_mapping(input) do
      [key, value] = String.split(input, "=")
      {key, parse_value(value)}
    end

    defp parse_value(input) do
      [x, y] =
        input
        |> String.splitter(",")
        |> Enum.map(&String.to_integer/1)

      {x, y}
    end

    def move(robot, seconds, {width, height}) do
      {x, y} = robot.position
      {dx, dy} = robot.velocity
      x = rem(x + dx * seconds, width)
      x = if x < 0, do: width + x, else: x
      y = rem(y + dy * seconds, height)
      y = if y < 0, do: height + y, else: y
      %Robot{robot | position: {x, y}}
    end
  end

  def part1(input) do
    [w, h] = System.argv() |> Enum.map(&String.to_integer/1)

    input
    |> parse()
    |> Stream.map(&Robot.move(&1, 100, {w, h}))
    |> Stream.map(& &1.position)
    |> Stream.map(&quadrant(&1, {w, h}))
    |> Stream.reject(&(&1 == :none))
    |> Enum.frequencies()
    |> Stream.map(&elem(&1, 1))
    |> Enum.product()
  end

  def part2(input) do
    [w, h] = System.argv() |> Enum.map(&String.to_integer/1)

    input
    |> parse()
    |> movement_stream({w, h})
    |> Stream.with_index()
    |> Stream.take(w * h)
    |> Stream.filter(fn {robots, _} -> has_tree?(robots) end)
    |> Enum.each(fn {robots, seconds} ->
      robots
      |> Stream.map(& &1.position)
      |> print_map({w, h})

      IO.puts("Seconds: #{seconds}\n")
    end)
  end

  defp parse(input) do
    input
    |> String.splitter("\n", trim: true)
    |> Enum.map(&Robot.parse/1)
  end

  defp quadrant({x, y}, {w, h}) when x < div(w, 2) and y < div(h, 2), do: :tl
  defp quadrant({x, y}, {w, h}) when x > div(w, 2) and y < div(h, 2), do: :tr
  defp quadrant({x, y}, {w, h}) when x < div(w, 2) and y > div(h, 2), do: :bl
  defp quadrant({x, y}, {w, h}) when x > div(w, 2) and y > div(h, 2), do: :br
  defp quadrant(_, _), do: :none

  defp print_map(positions, {w, h}) do
    positions = Enum.frequencies(positions)

    for y <- 0..(h - 1) do
      for x <- 0..(w - 1) do
        case positions[{x, y}] do
          nil -> IO.write(".")
          n -> n |> Integer.to_string(36) |> IO.write()
        end
      end

      IO.write("\n")
    end
  end

  defp movement_stream(robots, step \\ 1, {w, h}) do
    Stream.iterate(robots, fn robots ->
      Enum.map(robots, &Robot.move(&1, step, {w, h}))
    end)
  end

  defp has_tree?(robots) do
    positions =
      robots
      |> Stream.map(& &1.position)
      |> MapSet.new()

    positions
    |> Enum.any?(fn {x, y} ->
      Enum.all?(
        # Random guess at length, but it worked.
        Stream.iterate({x, y}, fn {x, y} -> {x + 1, y} end) |> Stream.take(10),
        fn loc -> loc in positions end
      )
    end)
  end
end

input = IO.read(:eof)
IO.puts("Part 1: #{Day14.part1(input)}")
IO.puts("Part 2: #{Day14.part2(input)}")
