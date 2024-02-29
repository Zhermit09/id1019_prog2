defmodule Philosophers.Process do
  def start(name, {lPID, rPID}, {mainPID, waiterPID}, i) do
    spawn_link(fn ->
      Enum.each(i..1, fn _ ->
        think(35)
        ask(waiterPID)

        IO.inspect("#{name} attempts the LEFT(#{inspect(lPID)}) chopstick")
        acquire(lPID)
        IO.inspect("#{name} acquires the LEFT(#{inspect(lPID)}) chopstick")

        IO.inspect("#{name} attempts the RIGHT(#{inspect(rPID)}) chopstick")
        acquire(rPID)
        IO.inspect("#{name} acquires the RIGHT(#{inspect(rPID)}) chopstick")

        release({lPID, rPID})
        send(waiterPID, :done)
        IO.inspect("#{name} released BOTH#{inspect({lPID, rPID})} chopsticks")
      end)

      IO.inspect("#{name} is done")
      send(mainPID, :done)
    end)
  end

  def start(name, {lPID, rPID}, mainPID, i) do
    spawn_link(fn ->
      Enum.each(i..1, fn _ ->
        think(35)

        IO.inspect("#{name} attempts the LEFT(#{inspect(lPID)}) chopstick")
        acquire(lPID)
        IO.inspect("#{name} acquires the LEFT(#{inspect(lPID)}) chopstick")

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

  def start(name, {lPID, rPID}, mainPID, i, strength) do
    IO.inspect("here")
    spawn_link(fn ->
      case Enum.reduce(i..1, strength, fn _, str ->
             case str > 0 do
               true ->
                 think(35)

                 IO.inspect("#{name} attempts the LEFT(#{inspect(lPID)}) chopstick")

                 case acquire(lPID, 50) do
                   :ok ->
                     IO.inspect("#{name} acquires the LEFT(#{inspect(lPID)}) chopstick")
                     IO.inspect("#{name} attempts the RIGHT(#{inspect(rPID)}) chopstick")

                     case acquire(rPID, 50) do
                       :ok ->
                         IO.inspect("#{name} acquires the RIGHT(#{inspect(rPID)}) chopstick")

                         release({lPID, rPID})
                         IO.inspect("#{name} released BOTH#{inspect({lPID, rPID})} chopsticks")
                         str

                       :timeout ->
                         release(lPID)
                         IO.inspect("#{name} GAVE UP the RIGHT(#{inspect(rPID)}) chopstick")
                         str - 1
                     end

                   :timeout ->
                     IO.inspect("#{name} GAVE UP the LEFT(#{inspect(lPID)}) chopstick")
                     str - 1
                 end

               false ->
                 0
             end
           end) do
        0 ->
        IO.inspect("#{name} got starved with #{i} iterations left")
          nil

        _ ->
        IO.inspect("#{name} is done")
          nil
      end

      send(mainPID, :done)
    end)
  end

  def start_async(name, {lPID, rPID}, mainPID, i, strength) do
    spawn_link(fn ->
      case Enum.reduce(i..1, strength, fn _, str ->
             case str > 0 do
               true ->
                 think(35)

                 IO.inspect("#{name} attempts the LEFT(#{inspect(lPID)}) chopstick")
                 IO.inspect("#{name} attempts the RIGHT(#{inspect(rPID)}) chopstick")
                 async({lPID, rPID})
                 listen({lPID, rPID}, str, name)

               false ->
                 0
             end
           end) do
        0 ->
        IO.inspect("#{name} got starved with #{i} iterations left")
          nil

        _ ->
        IO.inspect("#{name} is done")
          nil
      end

      send(mainPID, :done)
    end)
  end

  defp ask(waiterPID) do
    send(waiterPID, {:eat, self()})

    receive do
      :ok -> :ok
      :wait -> ask(waiterPID)
    end
  end

  defp listen({rPID, :right}, str, {name, lPID}) do
    case sync(50) do
      {_, ^rPID} ->
        IO.inspect("#{name} acquires the RIGHT(#{inspect(rPID)}) chopstick")

        # think(200)
        async_release({lPID, rPID})
        IO.inspect("#{name} released BOTH#{inspect({lPID, rPID})} chopsticks")
        str

      {_, _} ->
        listen({rPID, :right}, str, {name, lPID})

      :timeout ->
        async_release({lPID, rPID})
        IO.inspect("#{name} GAVE UP BOTH#{inspect({lPID, rPID})} chopsticks")
        str - 1
    end
  end

  defp listen({lPID, :left}, str, {name, rPID}) do
    case sync(50) do
      {_, ^lPID} ->
        IO.inspect("#{name} acquires the LEFT(#{inspect(lPID)}) chopstick")

        #think(200)
        async_release({lPID, rPID})
        IO.inspect("#{name} released BOTH#{inspect({lPID, rPID})} chopsticks")
        str

      {_, _} ->
        listen({lPID, :left}, str, {name, rPID})

      :timeout ->
        async_release({lPID, rPID})
        IO.inspect("#{name} GAVE UP BOTH#{inspect({lPID, rPID})} chopsticks")
        str - 1
    end
  end

  defp listen({lPID, rPID}, str, name) do
    case sync(50) do
      {_, ^lPID} ->
        IO.inspect("#{name} acquires the LEFT(#{inspect(lPID)}) chopstick")
        listen({rPID, :right}, str, {name, lPID})

      {_, ^rPID} ->
        IO.inspect("#{name} acquires the RIGHT(#{inspect(rPID)}) chopstick")
        listen({lPID, :left}, str, {name, rPID})

      {_, _} ->
        listen({lPID, rPID}, str, name)

      :timeout ->
        async_release({lPID, rPID})
        IO.inspect("#{name} GAVE UP BOTH#{inspect({lPID, rPID})} chopsticks")
        str - 1
    end
  end

  defp think(t) do
    Process.sleep(:rand.uniform(t))
  end

  defp async({lPID, rPID}) do
    send(lPID, {:async_acquire, self()})
    send(rPID, {:async_acquire, self()})
  end

  defp sync(timeout) do
    receive do
      {:granted, pID} -> {:granted, pID}
    after
      timeout -> :timeout
    end
  end

  defp acquire(pID) do
    send(pID, {:acquire, self()})

    receive do
      :granted -> :ok
    end
  end

  defp acquire(pID, timeout) do
    send(pID, {:acquire, self()})

    receive do
      :granted -> :ok
    after
      timeout -> :timeout
    end
  end

  defp async_release({lPID, rPID}) do
    send(lPID, {:release, self()})
    send(rPID, {:release, self()})
  end

  defp release({lPID, rPID}) do
    send(lPID, {:release, self()})
    send(rPID, {:release, self()})

    receive do
      :granted -> :ok
    end

    receive do
      :granted -> :ok
    end
  end

  defp release(pID) do
    send(pID, {:release, self()})

    receive do
      :granted -> :ok
    end
  end
end
