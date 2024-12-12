#!/usr/bin/env elixir

defmodule Day12 do
  def part1(input) do
    garden = parse(input)

    find_regions(garden)
    |> Stream.map(&cost(&1, garden))
    |> Enum.sum()
  end

  def part2(input) do
    garden = parse(input)

    find_regions(garden)
    |> Stream.map(&discounted_cost(&1, garden))
    |> Enum.sum()
  end

  defp parse(input) do
    input
    |> String.splitter("\n", trim: true)
    |> Stream.with_index()
    |> Stream.flat_map(fn {line, y} ->
      line
      |> String.splitter("", trim: true)
      |> Stream.with_index()
      |> Stream.map(fn {plant, x} -> {{x, y}, plant} end)
    end)
    |> Map.new()
  end

  defp find_regions(garden) do
    for {loc, plant} <- garden, reduce: [] do
      regions ->
        already? = Enum.any?(regions, &(loc in &1))

        if already? do
          regions
        else
          [scan_region(loc, plant, garden) | regions]
        end
    end
  end

  defp scan_region(loc, plant, garden, region \\ MapSet.new()) do
    cond do
      garden[loc] != plant ->
        region

      loc in region ->
        region

      true ->
        region = MapSet.put(region, loc)
        Enum.reduce(neighbors(loc), region, &scan_region(&1, plant, garden, &2))
    end
  end

  defp neighbors({x, y}) do
    [
      {x - 1, y},
      {x + 1, y},
      {x, y - 1},
      {x, y + 1}
    ]
  end

  defp cost(region, garden), do: MapSet.size(region) * perimeter(region, garden)

  defp discounted_cost(region, garden), do: MapSet.size(region) * num_sides(region, garden)

  defp perimeter(region, garden) do
    edges(region, garden)
    |> Enum.count()
  end

  defp num_sides(region, garden) do
    edges(region, garden)
    |> find_sides(region, garden)
    |> Enum.count()
  end

  defp edges(region, garden) do
    region
    |> Stream.flat_map(fn loc ->
      loc
      |> neighbors()
      |> Stream.filter(&(garden[&1] != garden[loc]))
      |> Stream.map(&{loc, direction(loc, &1)})
    end)
  end

  defp find_sides(edges, region, garden) do
    edge_types = Enum.group_by(edges, &elem(&1, 0), &elem(&1, 1))

    for edge <- edges, reduce: [] do
      sides ->
        already? = Enum.any?(sides, &(edge in &1))

        if already? do
          sides
        else
          [scan_side(edge, edge_types, region, garden) | sides]
        end
    end
  end

  defp scan_side({loc, dir} = edge, edges, region, garden, side \\ MapSet.new()) do
    if edge in side do
      side
    else
      side = MapSet.put(side, edge)

      neighbors(loc)
      |> Stream.filter(&is_map_key(edges, &1))
      |> Stream.flat_map(fn loc -> Stream.map(edges[loc], &{loc, &1}) end)
      |> Stream.filter(&match?({_, ^dir}, &1))
      |> Enum.reduce(side, &scan_side(&1, edges, region, garden, &2))
    end
  end

  defp direction({x1, _}, {x2, _}) when x2 > x1, do: :right
  defp direction({x1, _}, {x2, _}) when x2 < x1, do: :left
  defp direction({_, y1}, {_, y2}) when y2 > y1, do: :down
  defp direction({_, y1}, {_, y2}) when y2 < y1, do: :up
end

input = IO.read(:eof)
IO.puts("Part 1: #{Day12.part1(input)}")
IO.puts("Part 2: #{Day12.part2(input)}")
