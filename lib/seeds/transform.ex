defmodule Seeds.Transform do
  def part2([seeds | maps]) do #brute force
    [h | t] = transform2({seeds, maps})

    Enum.reduce(t, h, fn num, min ->
      case num < min do
        true -> num
        false -> min
      end
    end)
  end

  def transform2({[], _}) do
    []
  end

  def transform2({[seeds, length | rest], maps}) do
    [h | t] =
      Enum.map(seeds..(seeds + length - 1), fn seed ->

          Enum.reduce(maps, seed, fn map, acc ->
            find(map, acc)
          end)

      end)



    res =
      Enum.reduce(t, h, fn num, min ->
        case num < min do
          true -> num
          false -> min
        end
      end)

    [res | transform2({rest, maps})]
  end

  def transform([seeds | maps]) do
    [h | t] =
      Enum.map(seeds, fn seed ->
        Enum.reduce(maps, seed, fn map, acc ->
          find(map, acc)
        end)
      end)

    Enum.reduce(t, h, fn num, min ->
      case num < min do
        true -> num
        false -> min
      end
    end)
  end

  def find(map, key) do
    Enum.find_value(map, key, fn {rng, func} ->
      case key in rng do
        true -> func.(key)
        false -> nil
      end
    end)
  end
end
