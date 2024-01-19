defmodule Derivative.Main do
  def main do
    #filename = Enum.fetch!(args, 0)
    #text = File.read!(filename)

    input = String.to_charlist(String.downcase(String.trim(IO.gets("Expression: "))))
    IO.inspect(input)
    IO.inspect(:tokenizer.string(input))
  end
end

