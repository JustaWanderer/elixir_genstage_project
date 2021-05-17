defmodule ElixirGenstage.UniquePageProducerConsumer do
  use GenStage, restart: :transient

  def start_link(_) do
    GenStage.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(uniques_map) do
    {:producer_consumer, uniques_map,
     subscribe_to: [{ElixirGenstage.PageidProducer, max_demand: 20}]}
  end

  def handle_events(events, _from, seen) do
    {:registered_name, name} = Process.info(self(), :registered_name)
    IO.puts("#{name}: Processing #{length(events)} articles.")

    {events, seen} = get_unique(events, seen)

    IO.puts("#{name}: There are #{length(events)} unique articles.")

    {:noreply, events, seen}
  end

  defp get_unique([], seen) do
    {[], seen}
  end

  defp get_unique([h | t], seen) do
    if Map.has_key?(seen, h) do
      get_unique(t, seen)
    else
      seen = Map.put_new(seen, h, true)
      {rest, seen} = get_unique(t, seen)
      {[h | rest], seen}
    end
  end
end
