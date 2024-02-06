defmodule List.Main do
  alias List.MRF, as: MRF
  alias List.Recursive, as: List
  import Integer

  def main() do
    list = [1, 2, 3, 4, 5, 6, 7]

    IO.inspect(List._length(list))
    IO.inspect(List.even(list))
    IO.inspect(List.inc(list, 4))
    IO.inspect(List.sum(list))
    IO.inspect(List.dec(list, 4))
    IO.inspect(List.mul(list, 4))
    IO.inspect(List.odd(list))
    IO.inspect(List.prod(list))
    IO.inspect(List._div(list, 2))

    IO.puts("")

    IO.inspect(MRF.reducel(list, 0, fn x, _ -> x + 1 end))
    IO.inspect(MRF.reducer(list, 0, fn x, _ -> x + 1 end))

    IO.inspect(MRF.filterl(list, fn x -> Integer.is_even(x) end))
    IO.inspect(MRF.filterr(list, fn x -> Integer.is_even(x) end))
    IO.inspect(MRF.filtert(list, fn x -> Integer.is_even(x) end))

    IO.inspect(MRF.map(list, fn x -> 4 + x end))

    IO.inspect(MRF.reducel(list, 0, fn x, y -> x + y end))
    IO.inspect(MRF.reducer(list, 0, fn x, y -> x + y end))
    IO.inspect(MRF.map(list, fn x -> x - 4 end))
    IO.inspect(MRF.map(list, fn x -> 4 * x end))

    IO.inspect(MRF.filterl(list, fn x -> Integer.is_odd(x) end))
    IO.inspect(MRF.filterr(list, fn x -> Integer.is_odd(x) end))
    IO.inspect(MRF.filtert(list, fn x -> Integer.is_odd(x) end))

    IO.inspect(MRF.reducel(list, 1, fn x, y -> x * y end))
    IO.inspect(MRF.reducer(list, 1, fn x, y -> x * y end))

    IO.inspect(MRF.filterl(list, fn x -> rem(x, 2) == 0 end))
    IO.inspect(MRF.filterr(list, fn x -> rem(x, 2) == 0 end))
    IO.inspect(MRF.filtert(list, fn x -> rem(x, 2) == 0 end))

    IO.puts("")
    IO.inspect(MRF.reducel(list, 0, fn x, y -> x + y * y end))
    IO.inspect(MRF.reducer(list, 0, fn x, y -> x + y * y end))



    MRF.reducel(list, 0, fn x, y -> x + y * y end)
  end
end
