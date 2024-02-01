defmodule Interpreter.Map do
  def new() do
    %{}
  end

  def add(key, str) do
    Map.put(%{}, key, str)
  end

  def add(key, str, map) do
    Map.put(map, key, str)
  end

  def find(key, map) do
    {key, Map.get(map, key)}
  end

  def del(keys, map) do
    Map.drop(map, keys)
  end

  def take(keys, map) do
    {:ok, Map.take(map, keys)}
  end

  def merge(left, right) do
    Map.merge left, right
  end
end
