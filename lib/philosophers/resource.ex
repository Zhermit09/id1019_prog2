defmodule Philosophers.Resource do
  def start() do
    spawn_link(fn ->
      free()
      IO.inspect("Process Dead")
    end)
  end

  def free() do
    receive do
      {:acquire, pID} ->
        send(pID, :granted)
        busy(pID)

      {:release, pID} ->
        send(pID, :granted)
        free()

      :quit ->
        :ok
    end
  end

  def busy(pID) do
    receive do
      {:acquire, pId} ->
        send(pId, :denied)
        busy(pID)

      {:release, ^pID} ->
        send(pID, :granted)
        free()

      {:release, pId} ->
        send(pId, :denied)
        #IO.inspect({pId, :denied})
        busy(pID)

      :quit ->
        :ok
    end
  end
end
