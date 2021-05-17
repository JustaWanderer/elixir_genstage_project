defmodule WordCountCollector do
  use GenServer, restart: :transient

  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    {:ok, %{}}
  end

  def send_word_count(word_count) do
    GenServer.cast(__MODULE__, {:merge, word_count})
  end

  def get_word_count() do
    GenServer.call(__MODULE__, :get)
    |> Map.to_list()
    |> Enum.sort(fn {_, a}, {_, b} -> a >= b end)
  end

  def stop() do
    GenServer.cast(__MODULE__, :stop)
  end

  def handle_cast({:merge, word_count}, state) do
    {:noreply, Map.merge(state, word_count, fn _k, v1, v2 -> v1 + v2 end)}
  end

  def handle_cast(:stop, state) do
    {:stop, :normal, state}
  end

  def handle_call(:get, _from, state) do
    {:reply, state, state}
  end
end
