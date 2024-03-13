defmodule Huffman.Benchmark do
  alias Huffman.Huffman, as: HM

  @i 1000
  @k 1
  @warmup 0

  def main() do
    {:ok, file} = File.read("./lib/huffman/kallocain.txt")

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
      &HM.test/1,
      "huffman"
    }
    |> bench()
  end

  # Test Functions----------------------------------------------------------------------

  # ------------------------------------------------------------------------------------

  def bench({data, func, name}) do
    result =
      Enum.reduce(0..@i, "", fn x, string ->
        IO.puts("\tIteration #{x}")
        {time, _} =
          :timer.tc(fn ->
            Enum.each(1..@k, fn _ ->
              {split,_} = String.split_at(data, (x+1)*round(String.length(data) / @i))
              func.(String.to_charlist(split))
            end)
          end)

        formatted = Integer.to_string((x+1)*round(String.length(data) / @i)) |> String.pad_trailing(4, " ")
        string <> "#{formatted}\t#{time}\n"
      end)

    File.write!(
      "./lib/huffman/data/" <> name <> ".dat",
      "# function runs per sample: #{@k}\n\n" <> result
    )
  end
end
