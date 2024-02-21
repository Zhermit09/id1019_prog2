defmodule Philosophers.Benchmark do
  alias Philosophers.Main, as: Main
  alias Philosophers.Resource, as: Resource
  alias Philosophers.Process, as: PProcess

  @step 10
  @i 10
  @k 1
  @warmup 0

  def main() do
    IO.puts("Benchmark Started!")

    Enum.each(1..(@warmup + 1), fn x ->
      message = "Run #{x}:" |> String.pad_trailing(6, " ")
      IO.puts("#{message}\t#{DateTime.utc_now()}")
      test()
    end)

    IO.puts("Done!")
  end

  def test() do

    {
      fn n ->
        w = Main.waiter(4)
        c1 = Resource.start()
        c2 = Resource.start()
        c3 = Resource.start()
        c4 = Resource.start()
        c5 = Resource.start()

        PProcess.start(:A, {c1, c2}, self(), n, 10)
        PProcess.start(:B, {c2, c3}, self(), n, 10)
        PProcess.start(:C, {c3, c4}, self(), n, 10)
        PProcess.start(:D, {c4, c5}, self(), n, 10)
        PProcess.start(:E, {c5, c1}, self(), n, 10)
        Main.wait(5)

        Enum.each([c1, c2, c3, c4, c5, w], fn pID -> send(pID, :quit) end)
      end,
      "timeout35ms"
    }
    |> bench()

    {
      fn n ->
        w = Main.waiter(4)
        c1 = Resource.start()
        c2 = Resource.start()
        c3 = Resource.start()
        c4 = Resource.start()
        c5 = Resource.start()

        PProcess.start_async(:A, {c1, c2}, self(), n, 10)
        PProcess.start_async(:B, {c2, c3}, self(), n, 10)
        PProcess.start_async(:C, {c3, c4}, self(), n, 10)
        PProcess.start_async(:D, {c4, c5}, self(), n, 10)
        PProcess.start_async(:E, {c5, c1}, self(), n, 10)
        Main.wait(5)

        Enum.each([c1, c2, c3, c4, c5, w], fn pID -> send(pID, :quit) end)
      end,
      "async35ms"
    }
    |> bench()

    {
      fn n ->
        w = Main.waiter(4)
        c1 = Resource.start()
        c2 = Resource.start()
        c3 = Resource.start()
        c4 = Resource.start()
        c5 = Resource.start()

        PProcess.start(:A, {c1, c2}, {self(), w}, n)
        PProcess.start(:B, {c2, c3}, {self(), w}, n)
        PProcess.start(:C, {c3, c4}, {self(), w}, n)
        PProcess.start(:D, {c4, c5}, {self(), w}, n)
        PProcess.start(:E, {c5, c1}, {self(), w}, n)
        Main.wait(5)

        Enum.each([c1, c2, c3, c4, c5, w], fn pID -> send(pID, :quit) end)
      end,
      "waiter35ms"
    }
    |> bench()
  end

  # Test Functions----------------------------------------------------------------------

  # ------------------------------------------------------------------------------------

  def bench({func, name}) do
    result =
      Enum.reduce(0..@i, "", fn x, string ->
      IO.inspect(x)
        {time, _} =
          :timer.tc(fn ->
            Enum.each(1..@k, fn _ ->
              func.((x+1) * @step)
            end)
          end)

        formatted = Integer.to_string(x * @step) |> String.pad_trailing(4, " ")
        string <> "#{formatted}\t#{time}\n"
      end)

    File.write!(
      "./lib/philosophers/data/" <> name <> ".dat",
      "# function runs per sample: #{@k}\n\n" <> result
    )
  end
end
