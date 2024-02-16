defmodule Springs.Combo do
  def count([]) do
    {0, %{}}
  end

  def count([h | tail]) do
    {c1, mem1} = combo(h)
    {c2, mem2} = count(tail)
    {c1 + c2, mem1}
  end

  def combo([pat, seq]) do
    len = length(pat)
    sum = Enum.reduce(seq, 0, fn x, acc -> x + acc end)
    hash = Enum.count(pat, fn x -> x == ?# end)
    dot = Enum.count(pat, fn x -> x == ?. end)

    combo([pat, seq], {sum - hash, len - sum - dot}, [], %{})
  end

  def combo([[], seq], {0, 0}, acc, mem) do
    # IO.inspect({[[], seq], {0, 0}, acc, mem})
    # IO.puts("//////////////////////////////\n")
    case check([Enum.reverse(acc), seq], 0) do
      true -> {1, Map.put(mem, [[], seq], 1)}
      false -> {0, Map.put(mem, [[], seq], 0)}
    end
  end

  def combo([[h | pat], seq], {hash, dot}, acc, mem) do
    IO.inspect({[[h | pat], seq], {hash, dot}, acc, mem})
   # IO.inspect(Map.fetch(mem, {[h | pat], acc}))
   # IO.puts("\n")
IO.gets("wait")
    case Map.fetch(mem, [[h | pat], seq]) do
      {:ok, val} ->
        {val, mem}

      _ ->
        cond do
          h == ?? ->
            cond do
              hash > 0 && 0 < dot ->
                {c1, mem1} = combo([[?# | pat], seq], {hash - 1, dot}, acc, mem)
                {c2, mem2} = combo([[?. | pat], seq], {hash, dot - 1}, acc, mem1)

                {c1 + c2, Map.put(mem2, [[?? | pat], seq], c1 + c2)}

              hash > 0 ->
                {c1, mem1} = combo([[?# | pat], seq], {hash - 1, dot}, acc, mem)
                {c1, Map.put(mem1, [[?? | pat], seq], c1)}

              0 < dot ->
                {c1, mem1} = combo([[?. | pat], seq], {hash, dot - 1}, acc, mem)
                {c1, Map.put(mem1, [[?? | pat], seq], c1)}

              true ->
                :error
            end

          true ->
            {c1, mem1} = combo([pat, seq], {hash, dot}, [h | acc], mem)
            {c1, Map.put(mem1, [pat, seq], c1)}
        end
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
