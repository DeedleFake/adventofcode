#!/usr/bin/env elixir

Mix.install([:nx])

bincount = fn t ->
  max = Nx.reduce_max(t) |> Nx.to_number()
  freq = t |> Nx.to_list() |> Enum.frequencies()
  for(i <- 0..max//1, do: freq[i] || 0) |> Nx.tensor()
end

input = IO.read(:eof)
lines = input |> String.split("\n", trim: true)

arrays =
  Nx.tensor(
    for line <- lines do
      line
      |> String.splitter(" ", trim: true)
      |> Enum.map(&String.to_integer/1)
    end
  )

diff =
  Nx.sort(arrays[[.., 0]])
  |> Nx.subtract(Nx.sort(arrays[[.., 1]]))
  |> Nx.abs()
  |> Nx.sum()
  |> Nx.to_number()

freq = bincount.(arrays[[.., 1]])

sim =
  freq
  |> Nx.take(arrays[[.., 0]])
  |> Nx.multiply(arrays[[.., 0]])
  |> Nx.sum()
  |> Nx.to_number()

IO.puts("Answer to part 1: #{diff}")
IO.puts("Answer to part 2: #{sim}")
