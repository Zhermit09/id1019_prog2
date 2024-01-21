defmodule Derivative.Derivate do
  @type num :: {:num, number()}
  @type atomic :: num | {:var, atom()}
  @type func ::
          {:log, num}
          | {:root, num}
          | {:sin}
          | {:cos}
          | {:tan}
          | {:asin}
          | {:acos}
          | {:atan}
  @type expr ::
          {:+, expr, expr}
          | {:-, expr, expr}
          | {:*, expr, expr}
          | {:/, expr, expr}
          | {:^, expr, expr}
          | {func, expr}
          | {atomic}

  @spec derivate(expr, atom()) :: expr
  @spec num(number()) :: num

  #@e :math.exp(1)
  #@pi :math.pi()

  def derivate({:var, var}, var) do
    num(1)
  end

  def derivate({:var, _}, _) do
    num(0)
  end

  def derivate({:num, _}, _) do
    num(0)
  end

  def derivate({:+, e1, e2}, var) do
    d1 = derivate(e1, var)
    d2 = derivate(e2, var)

    add(d1, d2)
  end

  def derivate({:-, e1, e2}, var) do
    d1 = derivate(e1, var)
    d2 = derivate(e2, var)

    sub(d1, d2)
  end

  def derivate({:*, e1, e2}, var) do
    d1 = derivate(e1, var)
    d2 = derivate(e2, var)

    add(mul(d2, e1), mul(d1, e2))
  end

  def derivate({:/, e1, e2}, var) do
    d1 = derivate(e1, var)
    d2 = derivate(e2, var)

    _div(sub(mul(d1, e2), mul(d2, e1)), _exp(e2, num(2)))
  end

  def derivate({:^, e1, e2}, var) do
    d1 = derivate(e1, var)
    d2 = derivate(e2, var)

    mul(_exp(e1, e2), add(mul(d2, ln(e1)), _div(mul(d1, e2), e1)))
  end

  # ----Functions-------------------------------------------------------------------------------------------------------

  def derivate({{:log, base}, expr}, var) do
    d = derivate(expr, var)
    _div(d, mul(expr, ln(base)))
  end

  def derivate({:sin, expr}, var) do
    d = derivate(expr, var)
    mul(d, cos(expr))
  end

  def derivate({:cos, expr}, var) do
    d = derivate(expr, var)
    mul(d, sub(num(0), sin(expr)))
  end

  def derivate({:tan, expr}, var) do
    derivate(tan(expr), var)
  end

  def derivate({:asin, expr}, var) do
    d = derivate(expr, var)
    _div(d, _exp(sub(num(1), _exp(expr, num(2))), _div(num(1), num(2))))
  end

  def derivate({:acos, expr}, var) do
    d = derivate(expr, var)
    sub(num(0), _div(d, _exp(sub(num(1), _exp(expr, num(2))), _div(num(1), num(2)))))
  end

  def derivate({:atan, expr}, var) do
    d = derivate(expr, var)
    _div(d, add(num(1), _exp(expr, num(2))))
  end

  def derivate({{:root, num}, expr}, var) do
    derivate(root(num, expr), var)
  end

  # ----Auxiliary Functions---------------------------------------------------------------------------------------------

  def num(x) do
    {:num, x}
  end

  def add({:num, a}, {:num, b}) do
    num(a + b)
  end

  def add({:num, 0}, b) do
    b
  end

  def add(a, {:num, 0}) do
    a
  end

  def add(a, b) do
    {:+, a, b}
  end

  def sub({:num, a}, {:num, b}) do
    num(a - b)
  end

  def sub(a, {:num, 0}) do
    a
  end

  def sub(a, b) do
    {:-, a, b}
  end

  def mul({:num, a}, {:num, b}) do
    num(a * b)
  end

  def mul(a, {:num, b}) do
    case b do
      0 -> num(0)
      1 -> a
      _ -> {:*, a, {:num, b}}
    end
  end

  def mul({:num, a}, b) do
    case a do
      0 -> num(0)
      1 -> b
      _ -> {:*, {:num, a}, b}
    end
  end

  def mul(a, b) do
    {:*, a, b}
  end

  def _div(_, {:num, 0}) do
    :NAN
  end

  def _div({:num, 0}, _) do
    num(0)
  end

  def _div(a, {:num, 1}) do
    a
  end

  def _div({:num, a}, {:num, b}) do
    num(a / b)
  end

  def _div(a, a) do
    num(1)
  end

  def _div(a, b) do
    {:/, a, b}
  end

  def _exp(a, {:num, 0}) do
    case a do
      {:num, 0} -> :NAN
      _ -> num(1)
    end
  end

  def _exp({:num, 1}, _) do
    num(1)
  end

  def _exp(a, b) do
    {:^, a, b}
  end

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
            {{:log, {:num, base}}, expr}
        end

      {:var, var} ->
        cond do
          base == var ->
            num(1)

          true ->
            {{:log, {:num, base}}, expr}
        end

      _ ->
        {{:log, {:num, base}}, expr}
    end
  end

  def sin(expr) do
    {:sin, expr}
  end

  def cos(expr) do
    {:cos, expr}
  end

  def tan(expr) do
    _div(sin(expr), cos(expr))
  end

  def asin(expr) do
    {:asin, expr}
  end

  def acos(expr) do
    {:acos, expr}
  end

  def atan(expr) do
    {:atan, expr}
  end

  def root(pow, expr) do
    {:^, expr, _div(num(1), pow)}
  end
end
