defmodule Mandelbrot.Main do
  alias Mandelbrot.Mandel, as: Mandel
  alias Mandelbrot.PPM, as: PPM

  def main() do
    width = 2560
    height = 1440
    depth = 1_000_000

    x0 = -1.110001209754036100737
    y0 = 0.256449337113116666637
    w = 1.110001209754036100737 - 1.109885893526024989645

    k = w / width

    img = Mandel.mandelbrot(width, height, {x0, y0}, k, depth)
    PPM.save("mandelbrot", img)
    IO.puts("done")
  end
end
