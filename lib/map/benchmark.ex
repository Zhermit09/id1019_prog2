defmodule Map.Benchmark do
  alias Map.List, as: MList
  alias Map.Tree, as: MTree

  @step 30
  @i 100
  @k 10000
  @warmup 1

  def main() do
    data =
      Enum.map(1..(@i * @step), fn _ ->
        rand = :rand.uniform(999_999)
        {rand, rand}
      end)

    test_data =
      Enum.map(1..@k, fn _ ->
        rand = :rand.uniform(999_999)
        {rand, rand}
      end)

    IO.puts("Benchmark Started!")

    Enum.each(1..(@warmup + 1), fn x ->
      message = "Run #{x}:" |> String.pad_trailing(6, " ")
      IO.puts("#{message}\t#{DateTime.utc_now()}")
      test(data, test_data)
    end)

    IO.puts("Done!")
  end

  def test(data, test_data) do
    {
      data,
      test_data,
      &Map.Benchmark.newL/2,
      &Map.Benchmark.l_add/3,
      "l_add"
    }
    |> bench()

    {
      data,
      test_data,
      &Map.Benchmark.newL/2,
      &Map.Benchmark.l_find/3,
      "l_find"
    }
    |> bench()

    {
      data,
      test_data,
      &Map.Benchmark.newL/2,
      &Map.Benchmark.l_rem/3,
      "l_rem"
    }
    |> bench()

    # --------------------------------
    {
      data,
      test_data,
      &Map.Benchmark.newT/2,
      &Map.Benchmark.t_add/3,
      "t_add"
    }
    |> bench()

    {
      data,
      test_data,
      &Map.Benchmark.newT/2,
      &Map.Benchmark.t_find/3,
      "t_find"
    }
    |> bench()

    {
      data,
      test_data,
      &Map.Benchmark.newT/2,
      &Map.Benchmark.t_rem/3,
      "t_rem"
    }
    |> bench()

    # --------------------------------
    {
      data,
      test_data,
      &Map.Benchmark.newM/2,
      &Map.Benchmark.m_add/3,
      "m_add"
    }
    |> bench()

    {
      data,
      test_data,
      &Map.Benchmark.newM/2,
      &Map.Benchmark.m_find/3,
      "m_find"
    }
    |> bench()

    {
      data,
      test_data,
      &Map.Benchmark.newM/2,
      &Map.Benchmark.m_rem/3,
      "m_rem"
    }
    |> bench()
  end

  # Test Functions----------------------------------------------------------------------
  def l_add(map, test_data, y) do
    MList.add(map, Enum.at(test_data, y - 1))
  end

  def l_find(map, test_data, y) do
    {key, _} = Enum.at(test_data, y - 1)
    MList.find(map, key)
  end

  def l_rem(map, test_data, y) do
    {key, _} = Enum.at(test_data, y - 1)
    MList.remove(map, key)
  end

  def t_add(map, test_data, y) do
    MTree.add(map, Enum.at(test_data, y - 1))
  end

  def t_find(map, test_data, y) do
    {key, _} = Enum.at(test_data, y - 1)
    MTree.find(map, key)
  end

  def t_rem(map, test_data, y) do
    {key, _} = Enum.at(test_data, y - 1)
    MTree.remove(map, key)
  end

  def m_add(map, test_data, y) do
    {key, val} = Enum.at(test_data, y - 1)
    Map.put(map, key, val)
  end

  def m_find(map, test_data, y) do
    {key, _} = Enum.at(test_data, y - 1)
    Map.get(map, key)
  end

  def m_rem(map, test_data, y) do
    {key, _} = Enum.at(test_data, y - 1)
    Map.delete(map, key)
  end

  # Map Generators----------------------------------------------------------------------
  def newL(n, seq) do
    list = MList.new()
    #
    Enum.reduce(1..n, list, fn x, result -> MList.add(result, Enum.at(seq, x - 1)) end)
  end

  def newT(n, seq) do
    tree = MTree.new()
    Enum.reduce(1..n, tree, fn x, result -> MTree.add(result, Enum.at(seq, x - 1)) end)
  end

  def newM(n, seq) do
    Enum.reduce(1..n, %{}, fn x, result ->
      {key, val} = Enum.at(seq, x - 1)
      Map.put(result, key, val)
    end)
  end

  # ------------------------------------------------------------------------------------

  def bench({data, test_data, new_map, func, name}) do
    result =
      Enum.reduce(0..@i, "", fn x, string ->
        map = new_map.(x * @step, data)

        {time, _} =
          :timer.tc(fn ->
            Enum.each(1..@k, fn y ->
              func.(map, test_data, y)
            end)
          end)

        formatted = Integer.to_string(x * @step) |> String.pad_trailing(4, " ")
        string <> "#{formatted}\t#{time}\n"
      end)

    File.write!("./lib/map/data/" <> name <> ".dat", "# function runs per sample: #{@k}\n\n" <> result)
  end
end
