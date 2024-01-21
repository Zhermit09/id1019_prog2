defmodule Derivative.Main do
  def main do
    IO.puts("[Derivative Calculator]\n")
    IO.puts("############################################################################
[Supported Functions]

Addition        :f + g
Subtraction     :f - g
Multiplication  :f * g    | fg
Division        :f / g
Exponential     :f ^ g

Logarithmic     :log(f)  <-> ln(f) | log{base}(f)   #ignore {} when writing
Root            :sqrt(f)  | root{base}(f)           #ignore {} when writing

Trigonometric   :sin(f)
                :cos(f)
                :tan(f)

                :asin(f)
                :acos(f)
                :atan(f)
----------------------------------------------------------------------------
Input:          :f    = <- Give expression to derivate
                :var  = <- Give a differentiation variable, default 'x'
                :n    = <- Specify order of derivation, default '1'
############################################################################
\n")

    loop()
  end

  def loop() do
    expression = input_expr()
    var = input_var()
    n = input_int()

    {:ok, tokens, _} = :tokenizer.string(expression)
    {:ok, tree} = :parser.parse(tokens)

    IO.puts("\nInterpreted as: " <> stringify(tree) <>"\n")
    derivate(n, n, tree, var)
    IO.puts("\n")
    loop()
  end

  def derivate(1, n, tree, var) do
    result = Derivative.Derivate.derivate(tree, var)
    IO.puts("d#{var}#{n}: " <> stringify(result))
  end

  def derivate(i, n, tree, var) do
    result = Derivative.Derivate.derivate(tree, var)
    IO.puts("d#{var}#{n - i + 1}: " <> stringify(result))
    derivate(i - 1, n, result, var)
  end

  def stringify({:num, num}) do
    "#{num}"
  end

  def stringify({:var, var}) do
    "#{var}"
  end

  def stringify({{:log, {_, base}}, expr}) do
    case base do
      :e ->
        "ln(#{stringify(expr)})"

      _ ->
        "log#{base}(#{stringify(expr)})"
    end
  end

  def stringify({{:root, {_, num}}, expr}) do
    "root#{num}(#{stringify(expr)})"
  end

  def stringify({func, expr}) do
    "#{func}(#{stringify(expr)})"
  end

  def stringify({:+, e1, e2}) do
    "(#{stringify(e1)}+#{stringify(e2)})"
  end

  def stringify({:^, e1, e2}) do
    "(#{stringify(e1)})^(#{stringify(e2)})"
  end

  def stringify({:/, e1, e2}) do
    "#{stringify(e1)}/(#{stringify(e2)})"
  end

  def stringify({:*, e1, e2}) do
    "(#{stringify(e1)}#{stringify(e2)})"
  end

  def stringify({:-, {:num, 0}, e2}) do
    "-#{stringify(e2)}"
  end

  def stringify({op, e1, e2}) do
    "#{stringify(e1)}#{op}#{stringify(e2)}"
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
        # IO.puts("Using 'x' as per default")
        :x

      var ->
        char = String.at(var, 0)

        case char |> Integer.parse() do
          :error ->
            char |> String.to_atom()

          _ ->
            IO.puts("Error: no integers allowed")
            input_var()
        end
    end
  end

  def input_int() do
    case IO.gets("n = ") |> String.trim() |> String.downcase() do
      "" ->
        # IO.puts("Using '1' as per default")
        1

      string ->
        case string |> Integer.parse() do
          :error ->
            IO.puts("Error: no characters allowed")
            input_int()

          {int, _} ->
            case int > 0 do
              true ->
                int

              _ ->
                IO.puts("Error: integer must be greater than 0")
                input_int()
            end
        end
    end
  end
end
