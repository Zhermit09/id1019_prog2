defmodule Springs.Combo do
  def count([]) do
    0
  end

  def count([h | tail]) do
    combo(h) + count(tail)
  end

  def combo([pat, seq]) do
    len = length(pat)
    sum = Enum.reduce(seq, 0, fn x, acc -> x + acc end)
    hash = Enum.count(pat, fn x -> x == ?# end)
    dot = Enum.count(pat, fn x -> x == ?. end)

    combo([pat, seq], {sum - hash, len - sum - dot}, [])
  end

  def combo([[], seq], {0, 0}, acc) do

    case check([Enum.reverse(acc), seq], 0) do
      true -> 1
      false -> 0
    end
  end

  def combo([[h | pat], seq], {hash, dot}, acc) do

    cond do
      h == ?? ->
        cond do
          hash > 0 && 0 < dot ->
            combo([pat, seq], {hash - 1, dot}, [?# | acc]) +
              combo([pat, seq], {hash, dot - 1}, [?. | acc])

          hash > 0 ->
            combo([pat, seq], {hash - 1, dot}, [?# | acc])

          0 < dot ->
            combo([pat, seq], {hash, dot - 1}, [?. | acc])

          true ->
            :error
        end

      true ->
        combo([pat, seq], {hash, dot}, [h | acc])
    end
  end

  def check([[], []], acc) do
    acc == 0
  end

  def check([[], [num]], acc) do
    acc == num
  end

  def check([[h | tp], []], acc) do
    cond do
      acc == 0 ->
        cond do
          h == ?# ->
            false

          true ->
            check([tp, []], acc)
        end

      true ->
        false
    end
  end

  def check([[h | tp], [num | ts]], acc) do
    cond do
      acc == 0 ->
        cond do
          h == ?# ->
            check([tp, [num | ts]], acc + 1)

          true ->
            check([tp, [num | ts]], acc)
        end

      acc < num ->
        cond do
          h == ?# ->
            check([tp, [num | ts]], acc + 1)

          true ->
            false
        end

      acc == num ->
        cond do
          h == ?# ->
            false

          true ->
            check([tp, ts], 0)
        end
    end
  end
end
