#!/usr/bin/env elixir

Mix.install([:flow])

defmodule Day17 do
  import Bitwise

  def part1(input) do
    {output, _} =
      input
      |> parse()
      |> run_program()

    output |> Enum.join(",")
  end

  def part2(input) do
    state = parse(input)

    target =
      state.program
      |> Tuple.to_list()
      |> Enum.flat_map(&Tuple.to_list/1)

    [
      Stream.iterate(state.registers.a, &(&1 + 1)),
      Stream.iterate(state.registers.a, &(&1 - 1)) |> Stream.take_while(&(&1 >= 0))
    ]
    |> Flow.from_enumerables()
    |> Flow.filter(fn a ->
      state = put_in(state.registers.a, a)
      {output, _} = run_program(state)
      output == target
    end)
    |> Enum.at(0)
  end

  defp parse(input) do
    input
    |> String.splitter("\n", trim: true)
    |> Enum.reduce(%{registers: %{}, program: [], pc: 0}, fn
      <<"Register ", name::binary-1, ": ", value::binary>>, state ->
        name =
          case name do
            "A" -> :a
            "B" -> :b
            "C" -> :c
          end

        put_in(state.registers[name], String.to_integer(value))

      <<"Program: ", program::binary>>, state ->
        program =
          program
          |> String.splitter(",", trim: true)
          |> Stream.map(&String.to_integer/1)
          |> Stream.chunk_every(2)
          |> Enum.map(&List.to_tuple/1)
          |> List.to_tuple()

        put_in(state.program, program)
    end)
  end

  defp run_program(state, output \\ [])

  defp run_program(%{program: program, pc: pc} = state, output)
       when div(pc, 2) >= tuple_size(program),
       do: {Enum.reverse(output), state}

  defp run_program(state, output) do
    instruction = elem(state.program, div(state.pc, 2))
    {output, state} = perform_instruction(instruction, state, output)
    run_program(state, output)
  end

  defp perform_instruction({0, operand}, state, output) do
    d = 1 <<< combo_value(operand, state)
    state = update_in(state.registers.a, fn n -> div(n, d) end)
    {output, advance(state)}
  end

  defp perform_instruction({1, operand}, state, output) do
    state = update_in(state.registers.b, fn v -> bxor(v, operand) end)
    {output, advance(state)}
  end

  defp perform_instruction({2, operand}, state, output) do
    result = rem(combo_value(operand, state), 8)
    state = put_in(state.registers.b, result)
    {output, advance(state)}
  end

  defp perform_instruction({3, operand}, state, output) do
    state = if state.registers.a != 0, do: %{state | pc: operand}, else: advance(state)
    {output, state}
  end

  defp perform_instruction({4, _operand}, state, output) do
    state = update_in(state.registers.b, fn b -> bxor(b, state.registers.c) end)
    {output, advance(state)}
  end

  defp perform_instruction({5, operand}, state, output) do
    result = rem(combo_value(operand, state), 8)
    output = [result | output]
    {output, advance(state)}
  end

  defp perform_instruction({6, operand}, state, output) do
    n = state.registers.a
    d = 1 <<< combo_value(operand, state)
    state = put_in(state.registers.b, div(n, d))
    {output, advance(state)}
  end

  defp perform_instruction({7, operand}, state, output) do
    n = state.registers.a
    d = 1 <<< combo_value(operand, state)
    state = put_in(state.registers.c, div(n, d))
    {output, advance(state)}
  end

  defp combo_value(operand, _state) when operand in 0..3, do: operand
  defp combo_value(4, state), do: state.registers.a
  defp combo_value(5, state), do: state.registers.b
  defp combo_value(6, state), do: state.registers.c

  defp advance(state), do: update_in(state.pc, &(&1 + 2))
end

input = IO.read(:eof)
IO.puts("Part 1: #{Day17.part1(input)}")
IO.puts("Part 2: #{Day17.part2(input)}")
