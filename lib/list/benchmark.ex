defmodule List.Benchmark do
  alias List.MRF, as: MRF

  @step 10
  @i 200
  @k 100
  @warmup 1

  def main() do
    data =
      Enum.map(1..(@i * @step), fn _ ->
        rand = :rand.uniform(999_999)
        {rand, rand}
      end)

    IO.puts("Benchmark Started!")

    Enum.each(1..(@warmup + 1), fn x ->
      message = "Run #{x}:" |> String.pad_trailing(6, " ")
      IO.puts("#{message}\t#{DateTime.utc_now()}")
      test(data)
    end)

    IO.puts("Done!")
  end

  def test(data) do
    {
      data,
      &MRF.filter/2,
      fn x -> x > 500_000 end,
      "filter1"
    }
    |> bench()

    {
      data,
      &MRF.filter2/2,
      fn x -> x > 500_000 end,
      "filter2"
    }
    |> bench()

    {
      data,
      &MRF.filter3/2,
      fn x -> x > 500_000 end,
      "filter3"
    }
    |> bench()
  end

  # Test Functions----------------------------------------------------------------------

  # ------------------------------------------------------------------------------------

  def bench({data, func, cond, name}) do
    result =
      Enum.reduce(0..@i, "", fn x, string ->

        {time, _} =
          :timer.tc(fn ->
            Enum.each(1..@k, fn _ ->
              func.(data, cond)
            end)
          end)

        formatted = Integer.to_string(x * @step) |> String.pad_trailing(4, " ")
        string <> "#{formatted}\t#{time}\n"
      end)

    File.write!(
      "./lib/list/data/" <> name <> ".dat",
      "# function runs per sample: #{@k}\n\n" <> result
    )
  end
end
