defmodule Springs.Main do
  alias Springs.Comb, as: Comb

  def main() do
    {:ok, file} = File.read("./lib/springs/input.txt")

    list = parse_file(file)

    IO.inspect(list)
    IO.puts("\n\n")

    IO.inspect(Comb.count_comb(list))
  end

  def parse_file(file) do
    String.split(file, "\r\n")
    |> Enum.map(fn x ->
      [springs, damaged] = String.split(x, " ")

      status = String.to_charlist(springs)
      seq =
        Enum.map(String.split(damaged, ","), fn str ->
          {int, _} = Integer.parse(str)
          int
        end)

      [status, seq]
    end)
  end

  def pattern_split([]) do
    []
  end

  def pattern_split([h | tail]) do
    {i, rest} = count(tail, h, 1)
    [{List.to_atom([h]), i} | pattern_split(rest)]
  end

  def count([], _, i) do
    {i, []}
  end

  def count([h | tail], prev, i) do
    cond do
      prev == h -> count(tail, h, i + 1)
      true -> {i, [h | tail]}
    end
  end
end
