defmodule Springs.Comb do
  def count_comb([]) do
    []
  end

  def count_comb([h | tail]) do
    comb(h)
    count_comb(tail)
    # [check(h, 0) | count_comb(tail)]
  end

  def comb([pat, seq]) do
    len = length(pat)
    sum = Enum.reduce(seq, 0, fn x, acc -> x + acc end)
    hash = Enum.count(pat, fn x -> x == ?# end)
    dot = Enum.count(pat, fn x -> x == ?. end)
    #IO.inspect({[pat, seq], {sum - hash, len - sum - dot}})
    comb([pat, seq], {sum - hash, len - sum - dot}, [])
  end

  def comb([[], seq], {0, 0}, acc) do
    case check([acc, seq], 0) do
      true -> 1
      false -> 0
    end
  end

  def comb([[h | pat], seq], {hash, dot}, acc) do
    IO.inspect({[[h | pat], seq], {hash, dot}, acc})
    IO.gets("wait")
    cond do
      h == ?? ->
        cond do
          hash > 0 && 0 < dot ->
            comb([pat, seq], {hash - 1, dot}, [?# | acc]) +
              comb([pat, seq], {hash, dot - 1}, [?. | acc])

          hash > 0 ->
            comb([pat, seq], {hash - 1, dot}, [?# | acc])

          0 < dot ->
            comb([pat, seq], {hash, dot - 1}, [?. | acc])

          true ->
            :error
        end

      true ->
        comb([pat, seq], {hash, dot}, [h | acc])
    end
  end

  def check([[], []], acc) do
    acc == 0
  end

  def check([[], _], _) do
    false
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
