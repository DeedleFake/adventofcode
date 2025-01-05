#!/usr/bin/env elixir

defmodule Layout do
  def sigil_L(layout, []) do
    layout
    |> String.splitter("\n", trim: true)
    |> Stream.with_index()
    |> Stream.flat_map(fn {line, y} ->
      line
      |> String.splitter("", trim: true)
      |> Stream.with_index()
      |> Stream.reject(&match?({" ", _}, &1))
      |> Stream.map(fn {c, x} -> {c, {x, y}} end)
    end)
    |> Map.new()
  end
end

defmodule Keypad do
  use GenServer

  def start_link(opts) do
    {name, opts} = Keyword.split(opts, [:name])
    GenServer.start_link(__MODULE__, opts, name)
  end

  @impl true
  def init(opts) do
    opts = Keyword.validate!(opts, [:layout, next: nil])
    state = Map.new(opts)
    valid = state.layout |> Map.values() |> MapSet.new()
    state = state |> Map.put(:valid, valid) |> Map.put(:current, "A")

    {:ok, state}
  end

  @impl true
  def handle_call({:type, button}, from, state) do
    state = move_to([button], from, state)
    {:noreply, state}
  end

  @impl true
  def handle_cast({:type, buttons, from}, state) do
    state = move_to(buttons, from, state)
    {:noreply, state}
  end

  defp move_to(buttons, from, state, result \\ [])

  defp move_to([], from, %{next: nil} = state, result) do
    GenServer.reply(from, List.flatten(result))
    state
  end

  defp move_to([], from, state, result) do
    GenServer.cast(state.next, {:type, List.flatten(result), from})
    state
  end

  defp move_to([button | buttons], from, state, result) do
    result = [result, find_path(button, state), "A"]
    state = %{state | current: button}
    move_to(buttons, from, state, result)
  end

  defp find_path(goal, %{current: goal}), do: []

  defp find_path(goal, %{current: start, layout: layout}) do
    {sx, sy} = layout[start]
    {gx, gy} = layout[goal]

    dx = gx - sx
    dy = gy - sy

    mx = gen_path(dx, {"<", ">"})
    my = gen_path(dy, {"^", "v"})

    if dx >= 0 do
      [mx, my]
    else
      [my, mx]
    end
  end

  defp gen_path(d, {n, _p}) when d < 0, do: List.duplicate(n, -d)
  defp gen_path(d, {_n, p}) when d > 0, do: List.duplicate(p, d)
  defp gen_path(0, {_n, _p}), do: []
end

defmodule Pipeline do
  use Supervisor
  import Layout

  @numeric ~L"""
  789
  456
  123
   0A
  """

  @directional ~L"""
   ^A
  <v>
  """

  def start_link() do
    Supervisor.start_link(__MODULE__, [])
  end

  def type(button) do
    GenServer.call(Numeric, {:type, button})
  end

  @impl true
  def init([]) do
    children = [
      Supervisor.child_spec({Keypad, name: Dir2, layout: @directional}, id: :directional_2),
      Supervisor.child_spec({Keypad, name: Dir1, layout: @directional, next: Dir2},
        id: :directional_1
      ),
      {Keypad, name: Numeric, layout: @numeric, next: Dir1}
    ]

    Supervisor.init(children, strategy: :rest_for_one)
  end
end

defmodule Day21 do
  def part1(input) do
    {:ok, pipeline} = Pipeline.start_link()

    result =
      input
      |> parse()
      |> Stream.map(&{&1, calc_inputs(&1)})
      |> Stream.map(fn {code, inputs} -> complexity(code) * length(inputs) end)
      |> Enum.sum()

    Supervisor.stop(pipeline)
    result
  end

  def part2(input) do
    :not_implemented
  end

  defp parse(input) do
    input
    |> String.splitter("\n", trim: true)
    |> Enum.map(&String.split(&1, "", trim: true))
  end

  defp calc_inputs(buttons) do
    buttons |> Stream.map(&Pipeline.type/1) |> Stream.concat() |> Enum.to_list()
  end

  defp complexity(code) do
    {num, _} = code |> List.to_string() |> Integer.parse()
    num
  end
end

input = IO.read(:eof)
IO.puts("Part 1: #{Day21.part1(input)}")
IO.puts("Part 2: #{Day21.part2(input)}")
