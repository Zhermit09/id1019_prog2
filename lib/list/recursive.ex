defmodule List.Recursive do
  import Integer

  def _length([]) do
    0
  end

  def _length([_ | t]) do
    1 + _length(t)
  end

  def sum([]) do
    0
  end

  def sum([h | t]) do
    h + sum(t)
  end

  def prod([]) do
    1
  end

  def prod([h | t]) do
    h * prod(t)
  end

  def even([]) do
    []
  end

  def even([h | t]) do
    case Integer.is_even(h) do
      true -> [h | even(t)]
      false -> even(t)
    end
  end

  def odd([]) do
    []
  end

  def odd([h | t]) do
    case Integer.is_odd(h) do
      true -> [h | odd(t)]
      false -> odd(t)
    end
  end

  def _div([], _) do
    []
  end

  def _div([h | t], val) do
    case rem(h, val) do
      0 -> [h | _div(t, val)]
      _ -> _div(t, val)
    end
  end

  def inc([], _) do
    []
  end

  def inc([h | t], val) do
    [h + val | inc(t, val)]
  end

  def dec([], _) do
    []
  end

  def dec([h | t], val) do
    [h - val | dec(t, val)]
  end

  def mul([], _) do
    []
  end

  def mul([h | t], val) do
    [h * val | mul(t, val)]
  end

  def _rem([], _) do
    []
  end

  def _rem([h | t], val) do
    [rem(h, val) | _rem(t, val)]
  end
end
