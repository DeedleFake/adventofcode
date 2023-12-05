#!/usr/bin/env elixir

defmodule Day05 do
  defmodule Mapping do
    defstruct dst: 0, src: 0, length: 0

    def parse(str) do
      [first, second, third] = Day05.parse_nums(str)

      %Mapping{
        dst: first,
        src: second,
        length: third
      }
    end

    def map_list([], v), do: v

    def map_list([m | maps], v) do
      case Mapping.map(m, v) do
        :out_of_range -> map_list(maps, v)
        mv -> mv
      end
    end

    def map(m, v) do
      i = v - m.src

      cond do
        i < 0 or i >= m.length -> :out_of_range
        true -> m.dst + i
      end
    end
  end

  defmodule Almanac do
    defstruct seeds: [],
              maps: []

    def add_seeds(a, seeds) when is_binary(seeds),
      do: add_seeds(a, Enum.reverse(Day05.parse_nums(seeds)))

    def add_seeds(a, [seed | seeds]), do: add_seeds(add_seed(a, seed), seeds)
    def add_seeds(a, []), do: a
    def add_seed(a, seed), do: %{a | seeds: [seed | a.seeds]}

    def add_mapping(a, name, mapping) when is_binary(mapping),
      do: add_mapping(a, name, Mapping.parse(mapping))

    def add_mapping(a, name, mapping = %Mapping{}), do: %{a | maps: [{name, mapping} | a.maps]}

    def parse(input, state \\ %{a: %Almanac{}, mode: nil})
    def parse([], state), do: state.a
    def parse(["" | input], state), do: parse(input, state)

    def parse(["seeds: " <> seeds | input], state),
      do: parse(input, %{state | a: add_seeds(state.a, seeds)})

    def parse([line | input], state) do
      case String.split(line, " ", trim: true) do
        [name, "map:"] -> parse(input, %{state | mode: String.to_atom(name)})
        _ -> parse(input, %{state | a: add_mapping(state.a, state.mode, line)})
      end
    end

    def seed_locations(a),
      do:
        Stream.map(
          a.seeds,
          &map(a.maps, &1, [
            :"seed-to-soil",
            :"soil-to-fertilizer",
            :"fertilizer-to-water",
            :"water-to-light",
            :"light-to-temperature",
            :"temperature-to-humidity",
            :"humidity-to-location"
          ])
        )

    def seeds_to_ranges(a), do: %{a | seeds: expand_ranges(a.seeds)}

    defp map(_, v, []), do: v

    defp map(m, v, [next | maps]),
      do: map(m, Mapping.map_list(Keyword.get_values(m, next), v), maps)

    defp expand_ranges(nums, ranges \\ [])
    defp expand_ranges([], ranges), do: Stream.concat(Enum.reverse(ranges))

    defp expand_ranges([start, length | rem], ranges),
      do: expand_ranges(rem, [start..(start + length - 1) | ranges])
  end

  def parse_nums(str, nums \\ [])
  def parse_nums("", nums), do: Enum.reverse(nums)
  def parse_nums(" " <> rem, nums), do: parse_nums(rem, nums)

  def parse_nums(str, nums) do
    case Integer.parse(str) do
      {v, rem} -> parse_nums(rem, [v | nums])
      :error -> nums
    end
  end
end

almanac =
  IO.stream()
  |> Enum.map(&String.trim/1)
  |> Day05.Almanac.parse()

# Part 1:
almanac
|> Day05.Almanac.seed_locations()
|> Enum.min()
|> IO.puts()

# Part 2:
almanac
|> Day05.Almanac.seeds_to_ranges()
|> Day05.Almanac.seed_locations()
|> Enum.min()
|> IO.puts()
