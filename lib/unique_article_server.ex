defmodule UniqueArticleServer do
  use GenServer, restart: :transient

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{seen: %{}, total_calls: 0}, name: __MODULE__)
  end

  def init(state) do
    {:ok, state}
  end

  def unique?(name) do
    GenServer.call(__MODULE__, {:unique?, name})
  end

  def num_of_articles() do
    GenServer.call(__MODULE__, :num)
  end

  def stop() do
    GenServer.cast(__MODULE__, :stop)
  end

  def handle_cast(:stop, state) do
    {:stop, :normal, state}
  end

  def handle_call({:unique?, name}, _from, state) do
    if Map.has_key?(state.seen, name) do
      {:reply, false, %{state | total_calls: state.total_calls + 1}}
    else
      state = %{seen: Map.put(state.seen, name, true), total_calls: state.total_calls + 1}
      {:reply, true, state}
    end
  end

  def handle_call(:num, _from, state) do
    {:reply, {state.total_calls, length(Map.keys(state.seen))}, state}
  end
end
