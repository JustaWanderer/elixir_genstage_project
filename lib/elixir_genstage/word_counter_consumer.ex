defmodule ElixirGenstage.WordCounterConsumer do
  use ConsumerSupervisor, restart: :transient

  def start_link(_) do
    ConsumerSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children = [
      %{
        id: ElixirGenstage.WordCounter,
        start: {ElixirGenstage.WordCounter, :start_link, []},
        restart: :transient
      }
    ]

    opts = [
      strategy: :one_for_one,
      subscribe_to: [
        {ElixirGenstage.UniquePageProducerConsumer, max_demand: 20}
      ]
    ]

    ConsumerSupervisor.init(children, opts)
  end
end
