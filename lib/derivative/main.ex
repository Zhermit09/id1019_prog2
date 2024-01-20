defmodule Derivative.Main do
  def main do
    IO.puts("[Derivative Calculator]")

    expression = input_expr()
    var = input_var()
    int = input_int()

    {:ok, tokens, _} = :tokenizer.string(expression)
    IO.inspect(tokens)
    {:ok, tree} = :parser.parse(tokens)
    IO.inspect(tree)

    main()
  end

  def input_expr() do
    case IO.gets("f = ") |> String.trim() |> String.downcase() do
      "" ->
        IO.puts("Error: no expression received")
        input_expr()

      expression ->
        expression |> String.to_charlist()
    end
  end

  def input_var() do
    case IO.gets("var = ") |> String.trim() |> String.downcase() do
      "" ->
        #IO.puts("Using 'x' per default")
        ~c"x"

      var ->
        char = String.at(var, 0)

        case char |> Integer.parse() do
          :error ->
            char |> String.to_charlist()

          _ ->
            IO.puts("Error: no integers allowed")
            input_var()
        end
    end
  end

  def input_int() do
    case IO.gets("n = ") |> String.trim() |> String.downcase() do
      "" ->
        #IO.puts("Using '1' per default")
        1

      string ->
        case string |> Integer.parse() do
          :error ->
            IO.puts("Error: no characters allowed")
            input_int()

          {int, _} ->
            int
        end
    end
  end
end