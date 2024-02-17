defmodule Springs.Main do
  alias Springs.Combo, as: Combo

  def main() do
    {:ok, file} = File.read("./lib/springs/input.txt")

    list = parse_file(file, 5)
    IO.inspect(Combo.count(list))
  end

  def parse_file(file, i) do
    String.split(file, "\r\n")
    |> Enum.map(fn x ->
      [springs, damaged] = String.split(x, " ")

      list = String.to_charlist(springs)

      num =
        Enum.map(String.split(damaged, ","), fn str ->
          {int, _} = Integer.parse(str)
          int
        end)

      status =
        cond do
          i > 1 ->
            Enum.reduce(2..i, list, fn _, acc ->
              list ++ [?? | acc]
            end)

          true ->
            list
        end

      seq = Enum.reduce(1..i, [], fn _, acc -> num ++ acc end)

      [status, seq]
    end)
  end
end
