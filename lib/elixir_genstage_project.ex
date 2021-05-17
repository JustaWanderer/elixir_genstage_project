defmodule ElixirGenstageProject do
  def start() do
    IO.puts(
      "This app will count occurences of every word in most popular pages of en.wikipedia.org."
    )

    IO.puts("It will search over top 1000 articles for every month in a range.")
    IO.puts("It will also ensure that no article will be counted twice.")
    IO.puts("")

    {start_year, _} =
      IO.gets(
        "What year to begin searching? (note that WikiMedia api can refuse requests for older data) "
      )
      |> String.trim()
      |> Integer.parse()

    {start_month, _} =
      IO.gets("What month of #{start_year} to begin searching? ")
      |> String.trim()
      |> Integer.parse()
      |> min({12, nil})
      |> max({1, nil})

    {end_year, _} =
      IO.gets(
        "What year to end searching? "
      )
      |> String.trim()
      |> Integer.parse()

    {end_month, _} =
      IO.gets("What month of #{end_year} to end searching? ")
      |> String.trim()
      |> Integer.parse()
      |> min({12, nil})
      |> max({1, nil})

    case IO.gets("Limit the amount of articles? [y/n]") |> String.trim() do
      "y" ->
        {limit, _} =
          IO.gets("Maximum number of articles: ")
          |> String.trim()
          |> Integer.parse()
          |> max(1)
        init({{{start_year, start_month}, {end_year, end_month}}, limit})
      _ ->
        init({{{start_year, start_month}, {end_year, end_month}}, nil})
    end

    IO.puts("")
  end

  def stop() do
    Supervisor.stop(ElixirGenstageProjectSup)
  end

  def init(range \\ {{{2020, 1}, {2020, 1}}, 1000}) do
    children = [
      {UniqueArticleServer, []},
      {WordCountCollector, []},
      {ElixirGenstage.PageidProducer, range},
      {ElixirGenstage.UniquePageConsumer, []}
    ]

    Supervisor.start_link(children, strategy: :rest_for_one, name: ElixirGenstageProjectSup)
  end
end
