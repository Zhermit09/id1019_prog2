defmodule Huffman.Main do
  alias Huffman.Huffman, as: HM

  def main() do
    text = File.read!("./lib/huffman/kallocain.txt") |> String.to_charlist()
    freq = HM.freq(text)
    IO.inspect(freq)
    tree = HM.huffman(freq)
    IO.inspect(tree)
    entable = HM.encode_table(tree)
    IO.inspect(entable)
    encoded = HM.encode(text, entable)
    IO.inspect(encoded)
    detable = HM.decode_table(entable)
    IO.inspect(detable)
    decoded = HM.decode(encoded, detable)
    IO.puts(decoded)

    IO.inspect("Compression: ~#{Float.round(length(encoded) * 100 / (length(text) * 8.0), 2)}%")

    IO.inspect(
      "True Compression: ~#{Float.round((length(encoded) + length(freq) * 16) * 100 / (length(text) * 8.0), 2)}%"
    )
  end
end
