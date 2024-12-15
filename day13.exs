#!/usr/bin/env elixir

Mix.install([:nx])

defmodule Day13 do
  defmodule Machine do
    @enforce_keys [:buttons, :prize]
    defstruct @enforce_keys

    def parse(input) do
      machine =
        input
        |> String.splitter("\n", trim: true)
        |> Enum.reduce(%{buttons: %{}}, &parse_line/2)

      buttons =
        Nx.f64([
          Tuple.to_list(machine.buttons["A"]),
          Tuple.to_list(machine.buttons["B"])
        ])
        |> Nx.transpose()

      prize = Nx.f64(Tuple.to_list(machine.prize))

      %__MODULE__{buttons: buttons, prize: prize}
    end

    defp parse_line(<<"Button ", button::binary-1, ": ", line::binary>>, machine) do
      %{"X" => x, "Y" => y} =
        line
        |> String.splitter(",", trim: true)
        |> Stream.map(&String.trim/1)
        |> Stream.map(fn <<axis::binary-1, "+", amount::binary>> ->
          {axis, String.to_integer(amount)}
        end)
        |> Map.new()

      put_in(machine.buttons[button], {x, y})
    end

    defp parse_line(<<"Prize: ", line::binary>>, machine) do
      %{"X" => x, "Y" => y} =
        line
        |> String.splitter(",", trim: true)
        |> Stream.map(&String.trim/1)
        |> Stream.map(fn <<axis::binary-1, "=", amount::binary>> ->
          {axis, String.to_integer(amount)}
        end)
        |> Map.new()

      Map.put_new(machine, :prize, {x, y})
    end
  end

  def part1(input) do
    parse(input)
    |> Stream.map(fn %{buttons: buttons, prize: prize} ->
      solution = Nx.LinAlg.solve(buttons, prize) |> Nx.round() |> Nx.as_type(:s64)
      {buttons, prize, solution}
    end)
    |> Stream.filter(fn {buttons, prize, solution} ->
      Nx.multiply(buttons, solution) |> Nx.sum(axes: [1]) == prize
    end)
    |> Stream.map(&elem(&1, 2))
    |> Stream.map(&Nx.multiply(&1, Nx.tensor([3, 1])))
    |> Stream.map(&Nx.sum/1)
    |> Stream.map(&Nx.to_number/1)
    |> Enum.sum()
  end

  def part2(input) do
    parse(input)
    |> Stream.map(fn machine ->
      update_in(machine.prize, &Nx.add(&1, Nx.s64(10_000_000_000_000)))
    end)
    |> Stream.map(fn %{buttons: buttons, prize: prize} ->
      solution = Nx.LinAlg.solve(buttons, prize) |> Nx.round() |> Nx.as_type(:s64)
      {buttons, prize, solution}
    end)
    |> Stream.filter(fn {buttons, prize, solution} ->
      Nx.multiply(buttons, solution) |> Nx.sum(axes: [1]) == prize
    end)
    |> Stream.map(&elem(&1, 2))
    |> Stream.map(&Nx.multiply(&1, Nx.tensor([3, 1])))
    |> Stream.map(&Nx.sum/1)
    |> Stream.map(&Nx.to_number/1)
    |> Enum.sum()
  end

  defp parse(input) do
    input
    |> String.splitter("\n\n", trim: true)
    |> Enum.map(&Machine.parse/1)
  end
end

input = IO.read(:eof)
IO.puts("Part 1: #{Day13.part1(input)}")
IO.puts("Part 2: #{Day13.part2(input)}")
