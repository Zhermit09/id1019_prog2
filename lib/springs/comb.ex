defmodule Springs.Comb do
  def count_comb([]) do
    []
  end

  def count_comb([h | tail]) do
    [comb(h) | count_comb(tail)]
  end

  def comb([[], []]) do
    []
  end

  def comb([pat, seq]) do
    pl = length(pat)
    sl = length(seq)
    [head | tail] = pat

    cond do
      pl < sl ->
        case head do
          [{:"?", num}] ->
            {i, _} =
              Enum.reduce(seq, {0, -1}, fn x, {i, acc} ->
                cond do
                  num >= acc + x + 1 ->
                    {i + 1, acc + x + 1}

                  true ->
                    {i, acc}
                end
              end)

            {split, rest} = Enum.split(seq, i)
            [count(head, split) | comb([tail, rest])]

          [{:"#", _}] ->
            [split | rest] = seq
            [count(head, split) | comb([tail, rest])]

          _ ->
            :mix1
        end

      pl == sl ->
        case head do
          [{:"?", num}] ->
            [split | rest] = seq

            cond do
              num >= split -> [count(head, [split]) | comb([tail, rest])]
              true -> [comb([tail, seq])]
            end

          [{:"#", _}] ->
            [split | rest] = seq
            [count(head, split) | comb([tail, rest])]

          [{:"#", n1}, {:"?", n2} | tl] ->
            [split | rest] = seq

            cond do
              n1 + n2 == split ->
                [count([{:"#", split}], split) | comb([tl ++ tail, rest])]

              n1 + n2 > split ->
                [count([{:"#", split}], split) | comb([[[{:"?", n2} | tl] | tail], rest])]

              true ->
                :error
            end

          [{:"?", n1}, {:"#", n2} | tl] ->
            [split | rest] = seq

            cond do
              n1 + n2 == split ->
                [count([{:"#", split}], split) | comb([tl ++ tail, rest])]

              n1 + n2 > split ->
                [count([{:"#", split}], split) | comb([[[{:"?", n2} | tl] | tail], rest])]

              true ->
                :error
            end

          _ ->
            :mix2
        end

      pl > sl ->
        :fucked
    end
  end

  def count([{:"?", num}], seq) do
    sum = Enum.reduce(seq, -1, fn x, acc -> x + acc + 1 end)

    cond do
      num == sum -> 1
      num > sum -> :comb
      num < sum -> :error
    end
  end

  def count([{:"#", num}], length) do
    cond do
      num == length -> 1
      true -> :error
    end
  end

  def count(pat, seq) do
    :count
  end
end
