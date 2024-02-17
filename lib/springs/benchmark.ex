defmodule Springs.Benchmark do
  alias Springs.Main, as: Main
  alias Springs.Combo, as: Combo

  @step 1
  @i 15
  @k 1
  @warmup 1

  def main() do
    {:ok, file} = File.read("./lib/springs/input.txt")

    IO.puts("Benchmark Started!")

    Enum.each(1..(@warmup + 1), fn x ->
      message = "Run #{x}:" |> String.pad_trailing(6, " ")
      IO.puts("#{message}\t#{DateTime.utc_now()}")
      test(file)
    end)

    IO.puts("Done!")
  end

  def test(data) do
    {
      data,
      &Combo.count/1,
      "springs2"
    }
    |> bench()
  end

  # Test Functions----------------------------------------------------------------------

  # ------------------------------------------------------------------------------------

  def bench({data, func, name}) do
    result =
      Enum.reduce(0..@i, "", fn x, string ->
        {time, _} =
          :timer.tc(fn ->
            Enum.each(1..@k, fn _ ->
              func.(Main.parse_file(data, x+1))
            end)
          end)

        formatted = Integer.to_string(x * @step) |> String.pad_trailing(4, " ")
        string <> "#{formatted}\t#{time}\n"
      end)

    File.write!(
      "./lib/springs/data/" <> name <> ".dat",
      "# function runs per sample: #{@k}\n\n" <> result
    )
  end
end
