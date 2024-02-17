defmodule Springs.Combo do
  def count([]) do
    0
  end

  def count([h | tail]) do
    {c1, _} = check(h)
    c2 = count(tail)
    c1 + c2
  end

  def check([pat, seq]) do
    len = length(pat)
    sum = Enum.reduce(seq, 0, fn x, acc -> x + acc end)
    hash = Enum.count(pat, fn x -> x == ?# end)
    dot = Enum.count(pat, fn x -> x == ?. end)

    check([pat, seq], {sum - hash, len - sum - dot}, 0, %{})
  end

  def check([[], []], {0, 0}, 0, mem) do
    {1, mem}
  end

  def check([[], [num]], {0, 0}, acc, mem) do
    case num == acc do
      true -> {1, mem}
      false -> {0, mem}
    end
  end

  def check([[h | pat], []], {hash, dot}, acc, mem) do
    case Map.fetch(mem, {[h | pat], [], {hash, dot}}) do
      {:ok, val} ->
        {val, mem}

      _ ->
        case h do
          ?? ->
            cond do
              hash > 0 ->
                {0, Map.put(mem, {[h | pat], [], {hash, dot}}, 0)}

              0 < dot ->
                {c, new_mem} = check([pat, []], {hash, dot - 1}, acc, mem)
                {c, Map.put(new_mem, {[h | pat], [], {hash, dot}}, c)}
            end

          ?# ->
            {0, Map.put(mem, {[h | pat], [], {hash, dot}}, 0)}

          ?. ->
            {c, new_mem} = check([pat, []], {hash, dot}, acc, mem)
            {c, Map.put(new_mem, {[h | pat], [], {hash, dot}}, c)}
        end
    end
  end

  def check([[h | pat], [num | seq]], {hash, dot}, 0, mem) do
    case Map.fetch(mem, {[h | pat], [num | seq], {hash, dot}}) do
      {:ok, val} ->
        {val, mem}

      _ ->
        case h do
          ?? ->
            cond do
              hash > 0 && 0 < dot ->
                {c1, mem1} = check([pat, [num | seq]], {hash - 1, dot}, 1, mem)
                {c2, mem2} = check([pat, [num | seq]], {hash, dot - 1}, 0, mem1)

                {c1 + c2, Map.put(mem2, {[h | pat], [num | seq], {hash, dot}}, c1 + c2)}

              hash > 0 ->
                {c, new_mem} = check([pat, [num | seq]], {hash - 1, dot}, 1, mem)
                {c, Map.put(new_mem, {[h | pat], [num | seq], {hash, dot}}, c)}

              0 < dot ->
                {c, new_mem} = check([pat, [num | seq]], {hash, dot - 1}, 0, mem)
                {c, Map.put(new_mem, {[h | pat], [num | seq], {hash, dot}}, c)}
            end

          ?# ->
            {c, new_mem} = check([pat, [num | seq]], {hash, dot}, 1, mem)
            {c, Map.put(new_mem, {[h | pat], [num | seq], {hash, dot}}, c)}

          ?. ->
            {c, new_mem} = check([pat, [num | seq]], {hash, dot}, 0, mem)
            {c, Map.put(new_mem, {[h | pat], [num | seq], {hash, dot}}, c)}
        end
    end
  end

  def check([[h | pat], [acc | seq]], {hash, dot}, acc, mem) do
    case Map.fetch(mem, {[h | pat], [acc | seq], {hash, dot}}) do
      {:ok, val} ->
        {val, mem}

      _ ->
        case h do
          ?? ->
            cond do
              hash > 0 && 0 < dot ->
                {c1, mem1} = {0, Map.put(mem, {[h | pat], [acc | seq], {hash, dot}}, 0)}
                {c2, mem2} = check([pat, seq], {hash, dot - 1}, 0, mem1)

                {c1 + c2, Map.put(mem2, {[h | pat], [acc | seq], {hash, dot}}, c1 + c2)}

              hash > 0 ->
                {0, Map.put(mem, {[h | pat], [acc | seq], {hash, dot}}, 0)}

              0 < dot ->
                {c, new_mem} = check([pat, seq], {hash, dot - 1}, 0, mem)
                {c, Map.put(new_mem, {[h | pat], [acc | seq], {hash, dot}}, c)}
            end

          ?# ->
            {0, Map.put(mem, {[h | pat], [acc | seq], {hash, dot}}, 0)}

          ?. ->
            {c, new_mem} = check([pat, seq], {hash, dot}, 0, mem)
            {c, Map.put(new_mem, {[h | pat], [acc | seq], {hash, dot}}, c)}
        end
    end
  end

  def check([[h | pat], [num | seq]], {hash, dot}, acc, mem) do
    case Map.fetch(mem, {[h | pat], [num | seq], {hash, dot}}) do
      {:ok, val} ->
        {val, mem}

      _ ->
        case h do
          ?? ->
            cond do
              hash > 0 ->
                {c, new_mem} = check([pat, [num | seq]], {hash - 1, dot}, acc + 1, mem)
                {c, Map.put(new_mem, {[h | pat], [num | seq], {hash, dot}}, c)}

              0 < dot ->
                {0, Map.put(mem, {[h | pat], [num | seq], {hash, dot}}, 0)}
            end

          ?# ->
            {c, new_mem} = check([pat, [num | seq]], {hash, dot}, acc + 1, mem)
            {c, Map.put(new_mem, {[h | pat], [num | seq], {hash, dot}}, c)}

          ?. ->
            {0, Map.put(mem, {[h | pat], [num | seq], {hash, dot}}, 0)}
        end
    end
  end
end
