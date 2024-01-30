defmodule Evaluate.EvalExpr do
  @e :math.exp(1)
  @pi :math.pi()

  def evaluate_expression(expr, values) do
    # all_values = [{:e, @e}, {:pi, @pi} | values]
    #
    map(expr, values) |> simplify() |> loop()
  end

  def loop(old) do
    result = simplify(old)

    cond do
      result == old -> result
      true -> simplify(result)
    end
  end

  def num(x) do
    {:num, x}
  end

  def map({:num, num}, _) do
    {:num, num}
  end

  def map({:var, var}, []) do
    {:var, var}
  end

  def map({:var, var}, values) do
    [{atom, val} | tail] = values

    cond do
      var == atom -> num(val)
      true -> map({:var, var}, tail)
    end
  end

  def map({op, e1, e2}, values) do
    {op, map(e1, values), map(e2, values)}
  end

  # ----Functions-------------------------------------------------------------------------------------------------------

  def map({{:log, base}, expr}, values) do
    log(base, map(expr, values))
  end

  def map({{:root, num}, expr}, values) do
    root(num, map(expr, values))
  end

  def map({func, expr}, values) do
    {func, map(expr, values)}
  end

  # ----Simplify--------------------------------------------------------------------------------------------------------

  def simplify({:num, num}) do
    {:num, num}
  end

  def simplify({:var, var}) do
    {:var, var}
  end

  def simplify({op, e1, e2}) do
    cond do
      op == :+ -> add(simplify(e1), simplify(e2))
      op == :- -> sub(simplify(e1), simplify(e2))
      op == :* -> mul(simplify(e1), simplify(e2))
      op == :/ -> _div(simplify(e1), simplify(e2))
      op == :^ -> _exp(simplify(e1), simplify(e2))
      true -> IO.puts("Not Supported!")
    end
  end

  def simplify({func, exp}) do
    cond do
      func == :sin ->
        sin(exp)

      func == :cos ->
        cos(exp)

      func == :tan ->
        tan(exp)

      func == :asin ->
        asin(exp)

      func == :acos ->
        acos(exp)

      func == :atan ->
        atan(exp)

      true ->
        case func do
          {:log, num} -> log(num, exp)
          {:root, num} -> root(num, exp)
          _ -> IO.puts("Not Supported!")
        end
    end
  end

  # ----Add-----------------------------------------
  def add({:num, n1}, {:+, {:num, n2}, exp}) do
    add(num(n1 + n2), exp)
  end

  def add({:num, n1}, {:+, exp, {:num, n2}}) do
    add(num(n1 + n2), exp)
  end

  def add({:var, v1}, {:+, {:var, v2}, exp}) do
    add(add({:var, v1}, {:var, v2}), exp)
  end

  def add({:var, v1}, {:+, exp, {:var, v2}}) do
    add(add({:var, v1}, {:var, v2}), exp)
  end

  # ------------------------------------------------

  def add({:-, {:num, 0}, e1}, {:-, {:num, 0}, e2}) do
    sub(num(0), add(simplify(e1), simplify(e2)))
  end

  def add({:num, n1}, {:-, {:num, n2}, exp}) do
    sub(num(n1 + n2), exp)
  end

  def add({:num, n1}, {:-, exp, {:num, n2}}) do
    add(sub({:num, n1}, {:num, n2}), exp)
  end

  def add({:var, v1}, {:-, {:var, v2}, exp}) do
    sub(add({:var, v1}, {:var, v2}), exp)
  end

  def add({:var, v1}, {:-, exp, {:var, v2}}) do
    add(sub({:var, v1}, {:var, v2}), exp)
  end

  # ------------------------------------------------

  def add({:var, v}, {:*, {:var, v}, exp}) do
    mul(add(num(1), exp), {:var, v})
  end

  def add({:var, v}, {:*, exp, {:var, v}}) do
    mul(add(num(1), exp), {:var, v})
  end

  # ------------------------------------------------
  def add({:+, e1, e2}, exp) do
    add(exp, {:+, e1, e2})
  end

  def add({:-, e1, e2}, exp) do
    add(exp, {:-, e1, e2})
  end

  def add({:*, e1, e2}, exp) do
    add(exp, {:*, e1, e2})
  end

  # ------------------------------------------------
  def add({:num, a}, {:num, b}) do
    num(a + b)
  end

  def add({:num, 0}, b) do
    simplify(b)
  end

  def add(a, {:num, 0}) do
    simplify(a)
  end

  def add(a, a) do
    mul(num(2), simplify(a))
  end

  def add({:/, a, b}, {:/, c, d}) do
    _div(
      add(
        mul(simplify(a), simplify(d)),
        mul(simplify(c), simplify(d))
      ),
      mul(simplify(b), simplify(d))
    )
  end

  def add({:/, a, b}, c) do
    _div(add(simplify(a), mul(simplify(b), simplify(c))), simplify(b))
  end

  def add(a, {:/, b, c}) do
    _div(add(mul(simplify(a), simplify(c)), simplify(b)), simplify(c))
  end

  def add(a, b) do
    {:+, simplify(a), simplify(b)}
  end

  # ----Sub-----------------------------------------

  def sub({:-, {:num, 0}, e1}, e2) do
    {:-, {:num, 0}, add(simplify(e1), simplify(e2))}
  end

  # ------------------------------------------------
  def sub({:num, n1}, {:-, {:num, n2}, exp}) do
    add(sub({:num, n1}, {:num, n2}), exp)
  end

  def sub({:num, n1}, {:-, exp, {:num, n2}}) do
    sub(num(n1 + n2), exp)
  end

  def sub({:var, v1}, {:-, {:var, v2}, exp}) do
    add(sub({:var, v1}, {:var, v2}), exp)
  end

  def sub({:var, v1}, {:-, exp, {:var, v2}}) do
    sub(add({:var, v1}, {:var, v2}), exp)
  end

  # ------------------------------------------------
  def sub({:-, {:num, n1}, exp}, {:num, n2}) do
    sub(sub({:num, n1}, {:num, n2}), exp)
  end

  def sub({:-, exp, {:num, n1}, {:num, n2}}) do
    sub(exp, num(n1 + n2))
  end

  def sub({:-, {:var, v1}, exp}, {:var, v2}) do
    sub(sub({:var, v1}, {:var, v2}), exp)
  end

  def sub({:-, exp, {:var, v1}}, {:var, v2}) do
    sub(exp, add({:var, v1}, {:var, v2}))
  end

  # ------------------------------------------------
  def sub({:num, n1}, {:+, {:num, n2}, exp}) do
    sub(sub({:num, n1}, {:num, n2}), exp)
  end

  def sub({:num, n1}, {:+, exp, {:num, n2}}) do
    sub(sub({:num, n1}, {:num, n2}), exp)
  end

  def sub({:var, v1}, {:+, {:var, v2}, exp}) do
    sub(sub({:var, v1}, {:var, v2}), exp)
  end

  def sub({:var, v1}, {:+, exp, {:var, v2}}) do
    sub(sub({:var, v1}, {:var, v2}), exp)
  end

  # ------------------------------------------------
  def sub({:+, {:num, n1}, exp}, {:num, n2}) do
    add(sub({:num, n1}, {:num, n2}), exp)
  end

  def sub({:+, exp, {:num, n1}, {:num, n2}}) do
    add(sub({:num, n1}, {:num, n2}), exp)
  end

  def sub({:+, {:var, v1}, exp}, {:var, v2}) do
    add(sub({:var, v1}, {:var, v2}), exp)
  end

  def sub({:+, exp, {:var, v1}}, {:var, v2}) do
    add(sub({:var, v1}, {:var, v2}), exp)
  end

  # ------------------------------------------------

  def sub({:var, v}, {:*, {:var, v}, exp}) do
    mul(sub(num(1), exp), {:var, v})
  end

  def sub({:var, v}, {:*, exp, {:var, v}}) do
    mul(sub(num(1), exp), {:var, v})
  end

  # ------------------------------------------------

  def sub({:*, {:var, v}, exp}, {:var, v}) do
    mul(sub(exp, num(1)), {:var, v})
  end

  def sub({:*, exp, {:var, v}}, {:var, v}) do
    mul(sub(exp, num(1)), {:var, v})
  end

  # ------------------------------------------------

  def sub(a, {:num, 0}) do
    simplify(a)
  end

  def sub(a, a) do
    num(0)
  end

  def sub({:num, a}, {:num, b}) do
    cond do
      a == 0 -> {:-, {:num, 0}, {:num, b}}
      a >= b -> num(a - b)
      a < b -> sub(num(0), num(b - a))
    end
  end

  def sub({:/, a, b}, {:/, c, d}) do
    _div(
      sub(
        mul(simplify(a), simplify(d)),
        mul(simplify(c), simplify(d))
      ),
      mul(simplify(b), simplify(d))
    )
  end

  def sub({:/, a, b}, c) do
    _div(sub(simplify(a), mul(simplify(b), simplify(c))), simplify(b))
  end

  def sub(a, {:/, b, c}) do
    _div(sub(mul(simplify(a), simplify(c)), simplify(b)), simplify(c))
  end

  def sub(a, b) do
    {:-, simplify(a), simplify(b)}
  end

  # ----Mul-----------------------------------------
  def mul({:num, n1}, {:*, {:num, n2}, exp}) do
    mul(mul({:num, n1}, {:num, n2}), exp)
  end

  def mul({:num, n1}, {:*, exp, {:num, n2}}) do
    mul(mul({:num, n1}, {:num, n2}), exp)
  end

  def mul({:var, v1}, {:*, {:var, v2}, exp}) do
    mul(mul({:var, v1}, {:var, v2}), exp)
  end

  def mul({:var, v1}, {:*, exp, {:var, v2}}) do
    mul(mul({:var, v1}, {:var, v2}), exp)
  end

  # ------------------------------------------------
  def mul({:num, n1}, {:+, {:num, n2}, exp}) do
    add(mul({:num, n1}, {:num, n2}), mul({:num, n1}, exp))
  end

  def mul({:num, n1}, {:+, exp, {:num, n2}}) do
    add(mul({:num, n1}, {:num, n2}), mul({:num, n1}, exp))
  end

  def mul({:var, v1}, {:+, {:var, v2}, exp}) do
    add(mul({:var, v1}, {:var, v2}), mul({:var, v1}, exp))
  end

  def mul({:var, v1}, {:+, exp, {:var, v2}}) do
    add(mul({:var, v1}, {:var, v2}), mul({:var, v1}, exp))
  end

  # ------------------------------------------------
  def mul({:num, n1}, {:-, {:num, n2}, exp}) do
    sub(mul({:num, n1}, {:num, n2}), mul({:num, n1}, exp))
  end

  def mul({:num, n1}, {:-, exp, {:num, n2}}) do
    sub(mul({:num, n1}, exp), mul({:num, n1}, {:num, n2}))
  end

  def mul({:var, v1}, {:-, {:var, v2}, exp}) do
    sub(mul({:var, v1}, {:var, v2}), mul({:var, v1}, exp))
  end

  def mul({:var, v1}, {:-, exp, {:var, v2}}) do
    sub(mul({:var, v1}, exp), mul({:var, v1}, {:var, v2}))
  end

  def mul(e1, {:-, {:num, 0}, e2}) do
    sub({:num, 0}, mul(simplify(e1), simplify(e2)))
  end

  # ------------------------------------------------
  def mul({type, a}, {:/, {type, b}, c}) do
    _div(mul({type, a}, {type, b}), c)
  end

  def mul({type, a}, {:/, b, {type, c}}) do
    mul(_div({type, a}, {type, c}), b)
  end

  # ------------------------------------------------
  def mul(a, {:^, a, exp}) do
    _exp(a, add(num(1), exp))
  end

  # ------------------------------------------------
  def mul({:*, e1, e2}, exp) do
    mul(exp, {:*, e1, e2})
  end

  def mul({:+, e1, e2}, exp) do
    mul(exp, {:+, e1, e2})
  end

  def mul({:-, e1, e2}, exp) do
    mul(exp, {:-, e1, e2})
  end

  def mul({:^, e1, e2}, exp) do
    mul(exp, {:^, e1, e2})
  end

  # ------------------------------------------------
  def mul({:num, a}, {:num, b}) do
    num(a * b)
  end

  def mul(a, {:num, b}) do
    cond do
      b == 0 -> num(0)
      b == 1 -> simplify(a)
      true -> {:*, simplify(a), {:num, b}}
    end
  end

  def mul({:num, a}, b) do
    cond do
      a == 0 -> num(0)
      a == 1 -> simplify(b)
      true -> {:*, {:num, a}, simplify(b)}
    end
  end

  def mul({:/, a, b}, {:/, c, d}) do
    _div(mul(simplify(a), simplify(c)), mul(simplify(b), simplify(d)))
  end

  def mul({:/, a, b}, c) do
    _div(mul(simplify(a), simplify(c)), simplify(b))
  end

  def mul(a, {:/, b, c}) do
    _div(mul(simplify(a), simplify(b)), simplify(c))
  end

  def mul(a, a) do
    _exp(simplify(a), 2)
  end

  def mul({:^, a, m}, {:^, a, n}) do
    _exp(a, add(m, n))
  end

  def mul(a, b) do
    {:*, simplify(a), simplify(b)}
  end

  # ----Div-----------------------------------------
  def _div(_, {:num, 0}) do
    :NAN
  end

  def _div({:num, 0}, _) do
    num(0)
  end

  def _div(a, {:num, 1}) do
    simplify(a)
  end

  def _div(e1, {:-, {:num, 0}, e2}) do
    _div(sub({:num, 0}, simplify(e1)), simplify(e2))
  end

  # ----GCD-----------------------------------------

  def gcd(a, b) do
    cond do
      b == 0 -> a
      true -> gcd(b, rem(a, b))
    end
  end

  def _div({:num, a}, {:num, b}) when a == round(a) and b == round(b) do
    d = gcd(round(a), round(b))
    {:/, num(round(a / d)), num(round(b / d))}
  end

  # ------------------------------------------------
  def _div(a, a) do
    num(1)
  end

  def _div(a, {:^, a, exp}) do
    _div(num(1), _exp(a, sub(exp, num(1))))
  end

  def _div({:^, a, exp}, a) do
    _exp(a, sub(exp, num(1)))
  end

  # ------------------------------------------------
  def _div({:/, a, b}, {:/, c, d}) do
    _div(mul(simplify(a), simplify(d)), mul(simplify(b), simplify(c)))
  end

  def _div({:/, a, b}, c) do
    _div(simplify(a), mul(simplify(b), simplify(c)))
  end

  def _div(a, {:/, b, c}) do
    _div(mul(simplify(a), simplify(c)), simplify(b))
  end

  def _div({:^, a, m}, {:^, a, n}) do
    _exp(a, sub(m, n))
  end

  def _div(a, b) do
    {:/, simplify(a), simplify(b)}
  end

  # ----Exp-----------------------------------------
  def _exp(a, {:num, 0}) do
    case a do
      {:num, 0} -> :NAN
      _ -> num(1)
    end
  end

  def _exp(a, {:num, 1}) do
    a
  end

  def _exp({:num, 1}, _) do
    num(1)
  end

  def _exp(a, {:-, {:num, 0}, b}) do
    _div(num(1), _exp(simplify(a), simplify(b)))
  end

  def _exp({:^, a, m}, n) do
    _exp(simplify(a), mul(simplify(m), simplify(n)))
  end

  def _exp({:*, {:num, n1}, exp}, {:num, n2}) do
    mul(_exp({:num, n1}, {:num, n2}), _exp(exp, {:num, n2}))
  end

  def _exp({:*, exp, {:num, n1}}, {:num, n2}) do
    mul(_exp({:num, n1}, {:num, n2}), _exp(exp, {:num, n2}))
  end

  def _exp({:/, {:num, n1}, exp}, {:num, n2}) do
    _div(_exp({:num, n1}, {:num, n2}), _exp(exp, {:num, n2}))
  end

  def _exp({:/, exp, {:num, n1}}, {:num, n2}) do
    _div(_exp(exp, {:num, n2}), _exp({:num, n1}, {:num, n2}))
  end

  def _exp({:num, a}, {:num, b}) do
    result = :math.pow(a, b)

    cond do
      result == round(result) -> num(round(result))
      true -> num(result)
    end
  end

  def _exp(a, b) do
    {:^, simplify(a), simplify(b)}
  end

  # ------------------------------------------------

  def ln(expr) do
    log(num(:e), expr)
  end

  def log({:num, base}, expr) do
    case expr do
      {:num, num} ->
        cond do
          base == num ->
            num(1)

          num <= 0 ->
            :NAN

          true ->
            {{:log, {:num, base}}, simplify(expr)}
        end

      {:var, var} ->
        cond do
          base == var ->
            num(1)

          true ->
            {{:log, {:num, base}}, simplify(expr)}
        end

      _ ->
        {{:log, {:num, base}}, simplify(expr)}
    end
  end

  def sin(expr) do
    {:sin, simplify(expr)}
  end

  def cos(expr) do
    {:cos, simplify(expr)}
  end

  def tan(expr) do
    _div(sin(simplify(expr)), cos(simplify(expr)))
  end

  def asin(expr) do
    {:asin, simplify(expr)}
  end

  def acos(expr) do
    {:acos, simplify(expr)}
  end

  def atan(expr) do
    {:atan, simplify(expr)}
  end

  def root(pow, expr) do
    {:^, simplify(expr), _div(num(1), simplify(pow))}
  end
end
