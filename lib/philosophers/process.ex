defmodule Philosophers.Process do
  def start(name, {lPID, rPID}, i, mainPID) do
    spawn_link(fn ->
      Enum.each(1..i, fn _ ->
        think(1)

        IO.inspect("#{name} attempts the LEFT(#{inspect(lPID)}) chopstick")
        acquire(lPID)
        IO.inspect("#{name} acquires the LEFT(#{inspect(lPID)}) chopstick")

        think(300)

        IO.inspect("#{name} attempts the RIGHT(#{inspect(rPID)}) chopstick")
        acquire(rPID)
        IO.inspect("#{name} acquires the RIGHT(#{inspect(rPID)}) chopstick")

        release({lPID, rPID})
        IO.inspect("#{name} released BOTH#{inspect({lPID, rPID})} chopsticks")
      end)

      IO.inspect("#{name} is done")
      send(mainPID, :done)
    end)
  end

  def think(t) do
    Process.sleep(:rand.uniform(t))
  end

  def acquire(pID) do
    send(pID, {:acquire, self()})

    receive do
      :granted -> :ok
      :denied -> acquire(pID)
    end
  end

  def release({lPID, rPID}) do
    send(lPID, {:release, self()})

    receive do
      :granted -> :ok
      :denied -> raise "Philosopher does not have access to the LEFT(#{lPID}) chopstick"
    end

    send(rPID, {:release, self()})

    receive do
      :granted -> :ok
      :denied -> raise "Philosopher does not have access to the RIGHT(#{rPID}) chopstick"
    end
  end
end
