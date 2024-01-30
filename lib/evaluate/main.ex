defmodule Evaluate.Main do
  alias Evaluate.EvalExpr, as: Eval

  def main do
    IO.puts("[Expression Evaluator]\n")
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
                :var  = <- Give values to variables, leave empty to skip
############################################################################
\n")

    loop()
  end

  def loop() do
    expression = input_expr()
    map = input_var([])


    {:ok, tokens, _} = :tokenizer.string(expression)
    {:ok, tree} = :parser.parse(tokens)

    IO.puts("\nInterpreted as: " <> stringify(tree) <> "\n")
    IO.puts("\n")

    result = Eval.evaluate_expression(tree, map)
    IO.puts("exp = " <> stringify(result))
    loop()
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
    "(#{stringify(e1)})/(#{stringify(e2)})"
  end

  def stringify({:*, e1, e2}) do
    "(#{stringify(e1)})(#{stringify(e2)})"
  end

  def stringify({:-, {:num, 0}, e2}) do
    "-(#{stringify(e2)})"
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

  def input_var(list) do
    case IO.gets("var: ") |> String.trim() |> String.downcase() do
      "" ->
        list

      var ->
        char = String.at(var, 0)

        case char |> Integer.parse() do
          :error ->
            input_var([{String.to_atom(char), input_int(char)} | list])

          _ ->
            IO.puts("Error: no integers allowed")
            input_var(list)
        end
    end
  end

  def input_int(char) do
    case IO.gets("#{char} = ") |> String.trim() |> String.downcase() do
      "" ->
        IO.puts("Error: must give a value")
        input_int(char)

      string ->
        case string |> Integer.parse() do
          :error ->
            IO.puts("Error: no characters allowed")
            input_int(char)

          {int, _} ->
            int
        end
    end
  end
end
