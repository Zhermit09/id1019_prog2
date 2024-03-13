defmodule MorseCode.MorseCode do
  # The codes that you should decode:

  def base,
    do:
      ~c".- .-.. .-.. ..-- -.-- --- ..- .-. ..-- -... .- ... . ..-- .- .-. . ..-- -... . .-.. --- -. --. ..-- - --- ..-- ..- ..."

  def rolled,
    do:
      ~c".... - - .--. ... ---... .----- .----- .-- .-- .-- .-.-.- -.-- --- ..- - ..- -... . .-.-.- -.-. --- -- .----- .-- .- - -.-. .... ..--.. ...- .----. -.. .--.-- ..... .---- .-- ....- .-- ----. .--.-- ..... --... --. .--.-- ..... ---.. -.-. .--.-- ..... .----"

  # The decoding tree.
  #
  # The tree has the structure  {:node, char, long, short} | :nil
  #

  def tree() do
    {:node, :na,
     {:node, 116,
      {:node, 109,
       {:node, 111, {:node, :na, {:node, 48, nil, nil}, {:node, 57, nil, nil}},
        {:node, :na, nil, {:node, 56, nil, {:node, 58, nil, nil}}}},
       {:node, 103, {:node, 113, nil, nil},
        {:node, 122, {:node, :na, {:node, 44, nil, nil}, nil}, {:node, 55, nil, nil}}}},
      {:node, 110, {:node, 107, {:node, 121, nil, nil}, {:node, 99, nil, nil}},
       {:node, 100, {:node, 120, nil, nil},
        {:node, 98, nil, {:node, 54, {:node, 45, nil, nil}, nil}}}}},
     {:node, 101,
      {:node, 97,
       {:node, 119, {:node, 106, {:node, 49, {:node, 47, nil, nil}, {:node, 61, nil, nil}}, nil},
        {:node, 112, {:node, :na, {:node, 37, nil, nil}, {:node, 64, nil, nil}}, nil}},
       {:node, 114, {:node, :na, nil, {:node, :na, {:node, 46, nil, nil}, nil}},
        {:node, 108, nil, nil}}},
      {:node, 105,
       {:node, 117, {:node, 32, {:node, 50, nil, nil}, {:node, :na, nil, {:node, 63, nil, nil}}},
        {:node, 102, nil, nil}},
       {:node, 115, {:node, 118, {:node, 51, nil, nil}, nil},
        {:node, 104, {:node, 52, nil, nil}, {:node, 53, nil, nil}}}}}}
  end

  def parse(list) do
    List.to_string(list) |> String.split(" ", trim: true)
  end

  def decode(signal, tree) do
    Enum.reduce(signal, [], fn list, acc -> [decode_one(String.to_charlist(list), tree) | acc] end)
    |> Enum.reverse()
  end

  def decode_one([], {_, char, _, _}) do
    char
  end

  def decode_one([h | rest], {:node, char, l, s}) do
    case h do
      ?- -> decode_one(rest, l)
      ?. -> decode_one(rest, s)
      _ -> char
    end
  end

  def encode_table(tree) do
    encode_table(tree, [], %{})
  end

  def encode_table({:node, char, nil, nil}, acc, map) do
    Map.put(map, char, Enum.reverse(acc))
  end

  def encode_table(nil, _, map) do
    map
  end

  def encode_table({:node, char, l, s}, acc, map) do
    left_map =
      case char do
        :na -> map
        _ -> Map.put(map, char,  Enum.reverse(acc))
      end

    right_map = encode_table(l, [?- | acc], left_map)
    encode_table(s, [?. | acc], right_map)
  end

  def encode([last], map) do
    (Map.get(map, last))
  end

  def encode([h | msg], map) do
    (Map.get(map, h) ++ [?\s]) ++ encode(msg, map)
  end
end
