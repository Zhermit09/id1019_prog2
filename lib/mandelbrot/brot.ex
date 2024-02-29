defmodule Mandelbrot.Brot do
  alias Mandelbrot.ComplexNumbers, as: CN

  def mandelbrot(c, n) do
    check({0, 0}, c, 0, n)
  end

  def func(z, c) do
    CN.add(CN.sq(z), c)
  end

  def check(_, _, _, 0) do
    0
  end

  def check(z, c, i, n) do
    case CN.abs(z) > 2 do
      false -> check(func(z, c), c, i + 1, n - 1)
      true -> i
    end
  end
end
