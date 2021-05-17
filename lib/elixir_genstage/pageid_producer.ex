defmodule ElixirGenstage.PageidProducer do
  use GenStage, restart: :transient

  def start_link(spec) do
    GenStage.start_link(__MODULE__, spec, name: __MODULE__)
  end

  def init({range, limit}) do
    page_titles =
      range
      |> get_timestamps()
      |> Enum.map(fn {y, m} ->
        "https://wikimedia.org/api/rest_v1/metrics/pageviews/top/en.wikipedia.org/all-access/#{
          :io_lib.format("~4..0B", [y])
        }/#{:io_lib.format("~2..0B", [m])}/all-days"
      end)
      |> Enum.map(&HTTPoison.get(&1))
      |> Enum.map(fn {:ok, res} -> res.body end)
      |> Enum.map(&Poison.decode/1)
      |> Enum.map(fn {:ok, %{"items" => [%{"articles" => res} | _]}} -> res end)
      |> Enum.to_list()
      |> List.flatten()
      |> Enum.map(fn %{"article" => res} -> res end)

    if limit != nil do
      {page_titles, _} = page_titles |> Enum.split(limit)
      {:producer, page_titles}
    else
      {:producer, page_titles}
    end
  end

  defp get_timestamps({{year, from_month}, {year, to_month}}) do
    for m <- from_month..to_month, do: {year, m}
  end

  defp get_timestamps({{from_year, _from_month} = from, {to_year, _to_month} = to})
       when from_year < to_year do
    get_timestamps({from, {from_year, 12}}) ++
      get_timestamps({{from_year + 1, 1}, {to_year - 1, 12}}) ++
      get_timestamps({{to_year, 1}, to})
  end

  defp get_timestamps(_) do
    []
  end

  def handle_demand(_demand, [] = state) do
    IO.puts("Producer exhausted all articles, shutting down.")
    {:stop, :normal, state}
  end

  def handle_demand(demand, state) do
    {events, rest} = Enum.split(state, demand)

    {:noreply, events, rest}
  end
end
