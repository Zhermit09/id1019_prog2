defmodule Huffman.Huffman do
  def test(text) do
    entable = freq(text) |> huffman() |>encode_table()
    encoded = encode(text, entable)
    detable = decode_table(entable)
    decode(encoded, detable)
  end

  def freq(input) do
    freq(input, %{})
  end

  def freq([], freq) do
    Map.to_list(freq) |> Enum.sort_by(&elem(&1, 1))
  end

  def freq([char | rest], freq) do
    freq(rest, Map.update(freq, char, 1, fn x -> x + 1 end))
  end

  def huffman([{e1, v1}]) do
    {e1, v1}
  end

  def huffman([{e1, v1}, {e2, v2}]) do
    {{{e1, v1}, {e2, v2}}, v1 + v2}
  end

  def huffman([{e1, v1}, {e2, v2} | rest]) do
    case Enum.find_index(rest, &(elem(&1, 1) > v1 + v2)) do
      nil -> huffman(rest ++ [{{{e1, v1}, {e2, v2}}, v1 + v2}])
      idx -> huffman(List.insert_at(rest, idx, {{{e1, v1}, {e2, v2}}, v1 + v2}))
    end
  end

  def encode_table(tree) do
    encode_table(tree, [], %{})
  end

  def encode_table({{left, right}, _}, seq, map) do
    # IO.puts("LEFT: #{inspect(left)}\nRIGHT: #{inspect(right)}\nSEQ: #{inspect(Enum.reverse(seq))}\nMAP: #{inspect(map)}\n\n")
    # IO.gets("wait")
    new_map = encode_table(left, [0 | seq], map)
    encode_table(right, [1 | seq], new_map)
  end

  def encode_table({letter, _}, seq, map) do
    # IO.puts("LETTER: #{inspect(letter)}\nSEQ: #{inspect(Enum.reverse(seq))}\nMAP: #{inspect(map)}\n\n")
    # IO.gets("wait")
    Map.put(map, letter, Enum.reverse(seq))
  end

  def decode_table(entable) do
    Map.new(Enum.map(entable, fn {key, val} -> {val, key} end))
  end

  def encode([], _) do
    []
  end

  def encode([h | tail], table) do
    Map.get(table, h) ++ encode(tail, table)
  end

  def decode([], _) do
    []
  end

  def decode([h | tail], table) do
    #IO.puts("\n\n")
    decode(tail, [h], table)
  end

  def decode([], seq, table) do
    # IO.puts("SEQ: #{inspect(Enum.reverse(seq))}\nTABLE: #{inspect(table)}\nGET: #{inspect(Map.get(table, Enum.reverse(seq)))}\n\n")
    case Map.get(table, Enum.reverse(seq)) do
      nil -> :error
      ch -> [ch]
    end
  end

  def decode([h | tail], seq, table) do
    # IO.puts("HEAD: #{inspect(h)}\nTAIL: #{inspect(tail)}\nSEQ: #{inspect(Enum.reverse(seq))}\nTABLE: #{inspect(table)}\nGET: #{inspect(Map.get(table, Enum.reverse(seq)))}\n\n")
    case Map.get(table, Enum.reverse(seq)) do
      nil ->
        decode(tail, [h | seq], table)

      ch ->
        [ch | decode(tail, [h], table)]
    end
  end
end
