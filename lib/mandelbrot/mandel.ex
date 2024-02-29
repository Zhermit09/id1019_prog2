defmodule Mandelbrot.Mandel do
  alias Mandelbrot.Brot, as: Brot

  def mandelbrot(width, height, {x, y}, k, max) do
    trans = fn w, h ->
      {x + k * (w - 1), y - k * (h - 1)}
    end

    get_pic(width, height, trans, max, [])
  end

  def get_pic(width, height, trans, max, []) do
    Enum.reduce(height..1, [], fn h, acc ->
      row =
        Enum.reduce(width..1, [], fn w, a ->
          c = trans.(w, h)
          d = Brot.mandelbrot(c, max)
          [convert(d, max) | a]
        end)

      IO.puts("Row: #{h}")
      [row | acc]
    end)
  end

  @part 5
  @p 500
  def convert(d, max) do
    f = d * @part * @p / max
    i = trunc(f)
    off = trunc(255 * (f - i))

    case i do
      0 -> {off, 0, 0}
      1 -> {255, off, 0}
      2 -> {255 - off, 255, 0}
      3 -> {0, 255, off}
      4 -> {0, 255 - off, 255}
      _ -> {255, 255, 255}
    end
  end
end
