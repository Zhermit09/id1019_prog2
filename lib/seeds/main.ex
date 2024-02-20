defmodule Seeds.Main do
  alias Seeds.Transform, as: Transform

  def main() do
    {:ok, file} = File.read("./lib/seeds/input.txt")

    input = parse_file(file)
    IO.inspect(input)
    IO.inspect(Transform.part2(input))
  end

  def parse_file(file) do
    [head | tail] = String.split(file, "\r\n\r\n", trim: true)
    [_, s] = String.split(head, ":", trim: true)

    seeds =
      String.split(s, " ", trim: true)
      |> Enum.map(fn x ->
        {int, _} = Integer.parse(String.trim(x))
        int
      end)

    maps =
      Enum.map(tail, fn x ->
        [_, seq] = String.split(x, ":", trim: true)

        String.split(seq, "\r\n", trim: true)
        |> Enum.reduce(%{}, fn x, acc ->
          [dst_, src_, rng_] = String.split(x, " ", trim: true)
          {dst, _} = Integer.parse(String.trim(dst_))
          {src, _} = Integer.parse(String.trim(src_))
          {rng, _} = Integer.parse(String.trim(rng_))
          Map.put(acc, src..(src + rng - 1), fn x -> x - (src - dst) end)
        end)
      end)

    [seeds | maps]
  end
end
