defmodule Philosophers.Resource do
  def start() do
    spawn_link(fn ->
      free()
      #IO.inspect("Process Dead")
    end)
  end

  defp free() do
    receive do
      {:acquire, pID} ->
        send(pID, :granted)
        busy()
        {:async_acquire, pID} ->
          send(pID, {:granted, self()})
          busy(pID)
      :quit ->
        :ok
    end
  end

  defp busy() do
    receive do
      {:release, pID} ->
        send(pID, :granted)
        free()

      :quit ->
        :ok
    end
  end

  defp busy(pID) do
    receive do
      {:release, ^pID} ->
        send(pID, :granted)
        free()

      :quit ->
        :ok
    end
  end
end
