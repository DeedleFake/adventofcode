#!/usr/bin/env elixir

defmodule Day09 do
  def part1(input) do
    layout = parse(input)

    data =
      layout
      |> Stream.with_index()
      |> Stream.reject(&match?({-1, _}, &1))
      |> Enum.reverse()

    free =
      layout
      |> Stream.with_index()
      |> Stream.filter(&match?({-1, _}, &1))
      |> Stream.map(&elem(&1, 1))

    new_layout =
      Stream.zip(data, free)
      |> Stream.take_while(fn {{_, from}, to} -> to < from end)
      |> Enum.reduce(to_counters(layout), fn {{d, from}, to}, layout ->
        :counters.put(layout, to + 1, d)
        :counters.put(layout, from + 1, -1)
        layout
      end)
      |> stream_counters()

    checksum(new_layout)
  end

  def part2(input) do
    layout = parse(input)

    data = contiguous(layout) |> Stream.filter(fn {_, _, d} -> d >= 0 end) |> Enum.reverse()

    new_layout =
      for {from, fsize, d} <- data, reduce: to_counters(layout) do
        counters ->
          counters
          |> stream_counters()
          |> contiguous()
          |> Stream.filter(fn {_, _, d} -> d < 0 end)
          |> Stream.take_while(fn {to, _, _} -> to < from end)
          |> Enum.find(fn {_, s, _} -> s >= fsize end)
          |> case do
            {to, _, _} ->
              put_all_counters(counters, (to + 1)..(to + fsize)//1, d)
              put_all_counters(counters, (from + 1)..(from + fsize)//1, -1)
              counters

            nil ->
              counters
          end
      end
      |> stream_counters()

    checksum(new_layout)
  end

  defp parse(input) do
    input
    |> String.trim()
    |> String.splitter("", trim: true)
    |> Stream.map(&String.to_integer/1)
    |> Enum.reduce({[], 0, :data}, fn
      n, {result, file, :data} -> {result ++ List.duplicate(file, n), file + 1, :free}
      n, {result, file, :free} -> {result ++ List.duplicate(-1, n), file, :data}
    end)
    |> elem(0)
  end

  defp checksum(data) do
    data
    |> Stream.with_index()
    |> Stream.reject(&match?({-1, _}, &1))
    |> Stream.map(fn {d, i} -> d * i end)
    |> Enum.sum()
  end

  defp contiguous(layout) do
    layout
    |> Stream.with_index()
    |> Stream.chunk_by(&elem(&1, 0))
    |> Stream.map(fn [{d, i} | _] = f -> {i, length(f), d} end)
  end

  defp to_counters(nums) do
    counters = :counters.new(length(nums), [:write_concurrency])

    for {n, i} <- Stream.with_index(nums), reduce: counters do
      counters ->
        :counters.put(counters, i + 1, n)
        counters
    end
  end

  defp stream_counters(counters) do
    %{size: size} = :counters.info(counters)

    Stream.unfold(1, fn
      i when i > size -> nil
      i -> {:counters.get(counters, i), i + 1}
    end)
  end

  defp put_all_counters(counters, range, data) do
    for i <- range do
      :counters.put(counters, i, data)
    end

    :ok
  end
end

input = IO.read(:eof)
IO.puts("Part 1: #{Day09.part1(input)}")
IO.puts("Part 2: #{Day09.part2(input)}")
