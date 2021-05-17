defmodule ElixirGenstageProject do
  def start() do
    init(:ok)
  end

  def init(range \\ {{{2020, 1}, {2020, 1}}, 1000}) do
    children = [
      {ElixirGenstage.PageidProducer, range},
      {ElixirGenstage.UniquePageProducerConsumer, []},
      {ElixirGenstage.WordCounterConsumer, []},
      {WordCountCollector, []}
    ]

    Supervisor.start_link(children, strategy: :rest_for_one)
  end
end
