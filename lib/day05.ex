defmodule Day05 do
  use Advent

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

    def map_all(maps, data, results \\ [])
    def map_all([], _, results), do: Enum.uniq(results)
    def map_all([m | maps], data, results), do: map_all(maps, data, results ++ map(m, data))

    def map(m, data, results \\ [])
    def map(_, [], results), do: Enum.reverse(Enum.reject(results, &(Range.size(&1) == 0)))
    def map(m, data, results) when not is_list(data), do: map(m, [data], results)

    def map(m, [cur | data], results) when is_integer(cur),
      do: map(m, [cur..cur//1 | data], results)

    def map(m, [cur | data], results) do
      {pre, over, post} = split_range(cur, src_to_range(m))
      over = if Range.size(over) != 0, do: map_range(m, over), else: over
      map(m, data, [pre, over, post | results])
    end

    defp split_range(outer, inner) do
      {
        min(outer.first, inner.first)..min(outer.last, inner.first - 1)//1,
        max(outer.first, inner.first)..min(outer.last, inner.last)//1,
        max(outer.first, inner.last + 1)..max(outer.last, inner.last)//1
      }
    end

    defp src_to_range(m), do: m.src..(m.src + m.length - 1)//1

    defp map_range(m, r) do
      offset = r.first - m.src
      (m.dst + offset)..(m.dst + offset + Range.size(r) - 1)//1
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
        map(a.maps, a.seeds, [
          :"seed-to-soil",
          :"soil-to-fertilizer",
          :"fertilizer-to-water",
          :"water-to-light",
          :"light-to-temperature",
          :"temperature-to-humidity",
          :"humidity-to-location"
        ])

    def seeds_to_ranges(a), do: %{a | seeds: expand_ranges(a.seeds)}

    defp map(_, v, []), do: v

    defp map(m, v, [next | maps]),
      do: map(m, Mapping.map_all(Keyword.get_values(m, next), v), maps)

    defp expand_ranges(nums, ranges \\ [])
    defp expand_ranges([], ranges), do: Stream.concat(Enum.reverse(ranges))

    defp expand_ranges([start, length | rem], ranges),
      do: expand_ranges(rem, [start..(start + length - 1)//1 | ranges])
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

  def part1(io) do
    io
    |> Enum.map(&String.trim/1)
    |> Day05.Almanac.parse()
    |> Day05.Almanac.seed_locations()
    |> Enum.min()
    |> Enum.min()
  end

  def part2(io) do
    io
    |> Enum.map(&String.trim/1)
    |> Day05.Almanac.parse()
    |> Day05.Almanac.seeds_to_ranges()
    |> Day05.Almanac.seed_locations()
    |> Enum.min()
  end
end
