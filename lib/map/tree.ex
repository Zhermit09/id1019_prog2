defmodule Map.Tree do
  def new() do
    {}
  end

  def add({}, {key, val}) do
    {{key, val}, {}, {}}
  end

  def add({{nodeK, nodeV}, left, right}, {key, val}) do
    cond do
      key == nodeK -> {{nodeK, val}, left, right}
      key < nodeK -> {{nodeK, nodeV}, add(left, {key, val}), right}
      key > nodeK -> {{nodeK, nodeV}, left, add(right, {key, val})}
      true -> {:error, "Something went wrong"}
    end
  end

  def find({}, _) do
    nil
  end

  def find({{nodeK, nodeV}, left, right}, key) do
    cond do
      key == nodeK -> {nodeK, nodeV}
      key < nodeK -> find(left, key)
      key > nodeK -> find(right, key)
      true -> {:error, "Something went wrong"}
    end
  end

  def remove({}, _) do
    {}
  end

  def remove({{key, _}, {}, {}}, key) do
    {}
  end

  def remove({{key, _}, left, {}}, key) do
    left
  end

  def remove({{key, _}, {}, right}, key) do
    right
  end

  def remove({{key, _}, left, right}, key) do
    {keyS, valS} = successor(right)
    {{keyS, valS}, left, remove(right, keyS)}
  end

  def remove({{nodeK, nodeV}, left, right}, key) do
    cond do
      key < nodeK -> {{nodeK, nodeV}, remove(left, key), right}
      key > nodeK -> {{nodeK, nodeV}, left, remove(right, key)}
      true -> {:error, "Something went wrong"}
    end
  end

  def successor({{key, val}, {}, _}) do
    {key, val}
  end

  def successor({_, left, _}) do
    successor(left)
  end
end
