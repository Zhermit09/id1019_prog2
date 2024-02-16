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

    check([pat, seq], 0, {sum - hash, len - sum - dot}, %{})
  end

  def combo([[], seq], acc, {0, 0}, mem) do
    # #IO.inspect({[[], seq], {0, 0}, acc, mem})
    # #IO.puts("//////////////////////////////\n")
    # #case check([Enum.reverse(acc), seq], 0) do
    #  true -> {1, Map.put(mem, [[], seq], 1)}
    # false -> {0, Map.put(mem, [[], seq], 0)}
    # end
  end

  def combo([[h | pat], seq], {hash, dot}, acc, mem) do
    #IO.inspect({[[h | pat], seq], {hash, dot}, acc, mem})
    ## #IO.inspect(Map.fetch(mem, {[h | pat], acc}))
    #IO#.gets("wait")
    # #IO.puts("\n")

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

  def check([[], []], acc, {0, 0}, mem) do
    #IO.inspect({[[], []], acc, {0, 0}, mem})
    #IO.gets("wait")
    #IO.puts("\n")
    case acc == 0 do
      true -> {1, mem}
      false -> {0, mem}
    end
  end

  def check([[], [num]], acc, {hash, dot}, mem) do
    #IO.inspect({[[], [num]], acc, {hash, dot}, mem})
    #IO.gets("wait")
    #IO.puts("\n")
    case acc == num do
      true -> {1, mem}
      false -> {0, mem}
    end
  end

  def check([[h | tp], []], acc, {hash, dot}, mem) do
    #IO.inspect({[[h | tp], []], acc, {hash, dot}, mem})
    #IO.gets("wait")
    #IO.puts("\n")
    case Map.fetch(mem, [[h | tp], []]) do
      {:ok, val} ->
        {val, mem}

      _ ->
        cond do
          acc == 0 ->
            cond do
              h == ?# ->
                {0, Map.put(mem, [[h | tp], []], 0)}

              h == ?? ->
                cond do
                  0 < dot ->
                    {c1, mem1} = check([tp, []], acc, {hash, dot - 1}, mem)
                    {c1, Map.put(mem1, [[h | tp], []], c1)}

                  hash > 0 ->
                    {0, Map.put(mem, [[h | tp], []], 0)}

                  true ->
                    :error
                end

              h == ?. ->
                {c, new_mem} = check([tp, []], acc, {hash, dot - 1}, mem)
                {c, Map.put(new_mem, [[h | tp], []], c)}
            end

          true ->
            false
        end
    end
  end

  def check([[h | tp], [num | ts]], acc, {hash, dot}, mem) do
    #IO.inspect({[[h | tp], [num | ts]], acc, {hash, dot}, mem})
    #IO.gets("wait")
    #IO.puts("\n")
    case Map.fetch(mem, [[h | tp], [num | ts]]) do
      {:ok, val} ->
        {val, mem}

      _ ->
        cond do
          acc == 0 ->
            cond do
              h == ?# ->
                {c, new_mem} = check([tp, [num | ts]], acc + 1, {hash, dot}, mem)
                {c, Map.put(new_mem, [[h | tp], [num | ts]], c)}

              h == ?? ->
                cond do
                  hash > 0 && 0 < dot ->
                    {c1, mem1} = check([tp, [num | ts]], acc + 1, {hash - 1, dot}, mem)
                    {c2, mem2} = check([tp, [num | ts]], acc, {hash, dot - 1}, mem1)

                    IO.inspect({mem1})

                    {c1 + c2, Map.put(mem2, [[h | tp], [num | ts]], c1 + c2)}

                  hash > 0 ->
                    {c1, mem1} = check([tp, [num | ts]], acc + 1, {hash - 1, dot}, mem)
                    {c1, Map.put(mem1, [[h | tp], [num | ts]], c1)}

                  0 < dot ->
                    {c1, mem1} = check([tp, [num | ts]], acc, {hash, dot - 1}, mem)
                    {c1, Map.put(mem1, [[h | tp], [num | ts]], c1)}

                  true ->
                    :error
                end

              h == ?. ->
                {c, new_mem} = check([tp, [num | ts]], acc, {hash, dot}, mem)
                {c, Map.put(new_mem, [[h | tp], [num | ts]], c)}
            end

          acc < num ->
            cond do
              h == ?# ->
                {c, new_mem} = check([tp, [num | ts]], acc + 1, {hash, dot}, mem)
                {c, Map.put(new_mem, [[h | tp], [num | ts]], c)}

              h == ?? ->
                cond do
                  hash > 0 ->
                    {c1, mem1} = check([tp, [num | ts]], acc + 1, {hash - 1, dot}, mem)
                    {c1, Map.put(mem1, [[h | tp], [num | ts]], c1)}

                  0 < dot ->
                    {0, Map.put(mem, [[h | tp], [num | ts]], 0)}

                  true ->
                    :error
                end

              h == ?. ->
                {0, Map.put(mem, [[h | tp], [num | ts]], 0)}
            end

          acc == num ->
            cond do
              h == ?# ->
                {0, Map.put(mem, [[h | tp], [num | ts]], 0)}

              h == ?? ->
                cond do

                  hash > 0 && 0 < dot ->
                    {c2, mem2} = check([tp,  ts], 0, {hash, dot - 1}, mem)
                    {c2, Map.put(mem2, [[h | tp], [num | ts]], c2)}

                  0 < dot ->
                    {c, new_mem} = check([tp, ts], 0, {hash, dot - 1}, mem)
                    {c, Map.put(new_mem, [[h | tp], [num | ts]], c)}

                  hash > 0 ->
                    {0, Map.put(mem, [[h | tp], [num | ts]], 0)}

                  true ->
                    :error
                end

              h == ?. ->
                {c, new_mem} = check([tp, ts], 0, {hash, dot}, mem)
                {c, Map.put(new_mem, [[h | tp], [num | ts]], c)}
            end
        end
    end
  end
end
