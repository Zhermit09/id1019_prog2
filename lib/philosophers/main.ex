defmodule Philosophers.Main do
  alias Philosophers.Resource, as: Resource
  alias Philosophers.Process, as: PProcess

  def main() do
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

    PProcess.start(:A, {c1, c2}, 10, self())
    PProcess.start(:B, {c2, c3}, 10, self())
    PProcess.start(:C, {c3, c4}, 10, self())
    PProcess.start(:D, {c4, c5}, 10, self())
    PProcess.start(:E, {c5, c1}, 10, self())
    wait(5)

    Enum.each([c1, c2, c3, c4, c5], fn pID -> send(pID, :quit) end )
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
