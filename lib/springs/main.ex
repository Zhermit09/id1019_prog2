defmodule Springs.Main do
  def main() do
    IO.puts("Yeet")
    {:ok, file} = File.read("./lib/springs/input.txt")

    list = parse_file(file)

    IO.inspect(list)
  end

  def parse_file(file) do
    String.split(file, "\r\n")
    |> Enum.map(fn x ->
      [springs, damaged] = String.split(x, " ")

      status = pattern_split(String.to_charlist(springs))

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

  def pattern_split([h1 | tail]) do
    {i, rest} = count(tail, h1, 1)
    [{List.to_atom([h1]), i} | pattern_split(rest)]
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
