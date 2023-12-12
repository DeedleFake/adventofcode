defmodule Day10 do
  use Advent

  defmodule PipeMap do
    defstruct start: nil, pipes: %{}

    defimpl String.Chars do
      def to_string(map) do
        Day10.pipes_to_string(map.pipes, start: map.start)
      end
    end
  end

  def parse_map(lines) do
    map =
      for {line, y} <- lines |> Stream.with_index(),
          {tile, x} <- line |> String.to_charlist() |> Stream.with_index(),
          tile != ?.,
          reduce: %PipeMap{} do
        map ->
          if tile == ?S do
            %PipeMap{map | start: {x, y}}
          else
            %PipeMap{map | pipes: Map.put(map.pipes, {x, y}, tile)}
          end
      end

    %PipeMap{map | pipes: Map.put(map.pipes, map.start, start_tile(map))} |> shrink()
  end

  defp start_tile(map) do
    [t, b, l, r] = neighbors(map.start) |> Tuple.to_list() |> Enum.map(&map.pipes[&1])
    pipe_from_neighbors(t, b, l, r)
  end

  defp neighbors({x, y}) do
    {
      {x, y - 1},
      {x, y + 1},
      {x - 1, y},
      {x + 1, y}
    }
  end

  defp pipe_from_neighbors(t, b, _, _) when t in ~C"|7F" and b in ~C"|JL", do: ?|
  defp pipe_from_neighbors(t, _, l, _) when t in ~C"|7F" and l in ~C"-LF", do: ?J
  defp pipe_from_neighbors(t, _, _, r) when t in ~C"|7F" and r in ~C"-J7", do: ?L
  defp pipe_from_neighbors(_, b, l, _) when b in ~C"|JL" and l in ~C"-LF", do: ?7
  defp pipe_from_neighbors(_, b, _, r) when b in ~C"|JL" and r in ~C"-J7", do: ?F
  defp pipe_from_neighbors(_, _, l, r) when l in ~C"-LF" and r in ~C"-J7", do: ?-

  def pipes_to_string(pipes, opts \\ []) do
    [start: start] = Keyword.validate!(opts, start: nil)

    {_, {mx, my}} = bounds(pipes)

    for y <- 0..my, x <- 0..mx do
      if start == {x, y} do
        ?S
      else
        pipes[{x, y}] || ?.
      end
    end
    |> Stream.chunk_every(my + 1)
    |> Enum.join("\n")
  end

  defp bounds(pipes) do
    {{{minx, _}, _}, {{maxx, _}, _}} = pipes |> Enum.min_max_by(fn {{x, _}, _} -> x end)
    {{{_, miny}, _}, {{_, maxy}, _}} = pipes |> Enum.min_max_by(fn {{_, y}, _} -> y end)
    {{minx, miny}, {maxx, maxy}}
  end

  defp shrink(map) do
    {{mx, my}, _} = bounds(map.pipes)

    {sx, sy} = map.start
    new_start = {sx - mx, sy - my}

    new_pipes =
      for {{x, y}, pipe} <- map.pipes, reduce: %{} do
        pipes -> Map.put(pipes, {x - mx, y - my}, pipe)
      end

    %PipeMap{map | start: new_start, pipes: new_pipes}
  end

  def part1(io) do
    map = io |> Stream.map(&String.trim/1) |> parse_map()
    map.pipes |> pipes_to_string()
  end

  def part2(io) do
  end
end
