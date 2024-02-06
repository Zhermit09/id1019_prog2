defmodule List.MRF do
  def map([], _) do
    []
  end

  def map([h | t], func) do
    [func.(h) | map(t, func)]
  end

  def reducel([], buff, _) do
    buff
  end

  def reducel([h | t], buff, func) do
    reducel(t, func.(buff, h), func)
  end

  def reducer([], buff, _) do
    buff
  end

  def reducer([h | t], buff, func) do
    func.(reducer(t, buff, func), h)
  end

  def filterl([], _) do
    []
  end

  def filterl([h | t], func) do
    case func.(h) do
      true -> [h | filterl(t, func)]
      _ -> filterl(t, func)
    end
  end

  def filterr(list, func) do
    filterr(list, func, [])
  end

  def filterr([], _, buff) do
    buff
  end

  def filterr([h | t], func, buff) do
    case func.(h) do
      true -> filterr(t, func, buff ++ [h])
      _ -> filterr(t, func, buff)
    end
  end

  def filtert(list, func) do
    filtert(list, func, [])
  end

  def filtert([], _, buff) do
    buff
  end

  def filtert([h | t], func, buff) do
    case func.(h) do
      true -> filtert(t, func, [h | buff])
      _ -> filtert(t, func, buff)
    end
  end
end
