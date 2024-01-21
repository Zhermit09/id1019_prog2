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

    add(mul(e1, d2), mul(d1, e2))
  end

  def derivate({:/, e1, e2}, var) do
    d1 = derivate(e1, var)
    d2 = derivate(e2, var)


    _div(sub(mul(d1, e2), mul(e1, d2)), _exp(e2, num(2)))
  end

  def derivate({:^, e1, e2}, var) do
    d1 = derivate(e1, var)
    d2 = derivate(e2, var)

    mul(_exp(e1, e2), add(mul(d2, ln(e1)), _div(mul(e2, d1), e1)))
  end

  # ----Functions-------------------------------------------------------------------------------------------------------

  def derivate({{:log, base}, expr}, var) do
    {:/}
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
   """
 cond do
      is_integer(a) and is_integer(b) ->
        d = gcd(a, b)

        {:/, num(a / d), num(b / d)}

      true ->

    end
  """
   num(a / b)
  end

  """

  def gcd(x, y) do
    case y do
      0 -> x
      _ -> gcd(y, rem(x, y))
    end
  end
  """
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


  def ln(x) do
    log(num(:e), x)
  end

  def log(base, x) do
    case x do
      {:num, num} ->
        cond do
          base === x ->
            num(1)

          num <= 0 ->
            :error

          true ->
            {{:log, base}, x}
        end

      _ ->
        {{:log, base}, x}
    end
  end
end
