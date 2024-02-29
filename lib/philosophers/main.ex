defmodule Philosophers.Main do
  alias Philosophers.Resource, as: Resource
  alias Philosophers.Process, as: PProcess

  def main() do
    w = waiter(4)
    IO.puts("Waiter = #{inspect(w)}")

    c1 = Resource.start()
    IO.puts("Chopstick 1 = #{inspect(c1)}")
    c2 = Resource.start()
    IO.puts("Chopstick 2 = #{inspect(c2)}")
    c3 = Resource.start()
    IO.puts("Chopstick 3 = #{inspect(c3)}")
    c4 = Resource.start()
    IO.puts("Chopstick 4 = #{inspect(c4)}")
    c5 = Resource.start()
    IO.puts("Chopstick 5 = #{inspect(c5)}")
    IO.puts("\n")

    PProcess.start(:A, {c1, c2}, self(), 10)
    PProcess.start(:B, {c3, c2}, self(), 10)
    PProcess.start(:C, {c3, c4}, self(), 10)
    PProcess.start(:D, {c5, c4}, self(), 10)
    PProcess.start(:E, {c5, c1}, self(), 10)
    wait(5)

    Enum.each([c1, c2, c3, c4, c5, w], fn pID -> send(pID, :quit) end)
  end

  def waiter(i) do
    spawn_link(fn ->
      count(i)
      IO.inspect("Waiter Dead")
    end)
  end

  defp count(0) do
    receive do
      {:eat, pID} ->
        send(pID, :wait)
        count(0)

      :done ->
        count(1)

      :quit ->
        :ok
    end
  end

  defp count(i) do
    receive do
      {:eat, pID} ->
        send(pID, :ok)
        count(i - 1)

      {:done, _} ->
        count(i + 1)

      :quit ->
        :ok
    end
  end

  def wait(0) do
    :ok
  end

  def wait(i) do
    receive do
      :done -> wait(i - 1)
    end
  end
end
