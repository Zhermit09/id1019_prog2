defmodule Map.List do
  def new() do
    []
  end

  def add([], item) do
    [item]
  end

  def add(list, {key, val}) do
    [{nextK, nextV} | rest] = list

    cond do
      nextK < key -> [{nextK, nextV} | add(rest, {key, val})]
      nextK == key -> [{nextK, val} | rest]
      nextK > key -> [{key, val} | list]
      true -> {:error, "Something went wrong"}
    end
  end

  def find([], _) do
    nil
  end

  def find(list, key) do
    [{nextK, val} | rest] = list

    cond do
      nextK < key -> find(rest, key)
      nextK == key -> {nextK, val}
      nextK > key -> nil
      true -> {:error, "Something went wrong"}
    end
  end

  def remove([], _) do
    []
  end

  def remove(list, key) do
    [{nextK, val} | rest] = list

    cond do
      nextK < key -> [{nextK, val} | remove(rest, key)]
      nextK == key -> rest
      nextK > key -> list
      true -> {:error, "Something went wrong"}
    end
  end
end
