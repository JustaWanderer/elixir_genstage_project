defmodule ElixirGenstage.WordCounter do
  def start_link(event) do
    Task.start_link(fn -> init(event) end)
  end

  def init(article_name) do
    if UniqueArticleServer.unique?(article_name) do
      article =
        article_name
        |> (&HTTPoison.get(
              "https://en.wikipedia.org/w/api.php",
              [timeout: 15_000],
              params: [
                action: "query",
                format: "json",
                titles: &1,
                prop: "extracts",
                explaintext: true
              ]
            )).()

      case article do
        {:error, _} ->
          {:stop, :normal}

        {:ok, %{body: res}} ->
          case Poison.decode(res) do
            {:error, _} ->
              {:stop, :normal}

            {:ok, %{"query" => %{"pages" => data}}} ->
              data
              |> Map.to_list()
              |> Enum.filter(fn {id, _} -> id != "-1" end)
              |> Enum.map(fn {_, %{"extract" => res}} -> res end)
              |> Enum.reduce("", &(&1 <> &2))
              |> String.replace(
                [
                  "\n",
                  "\"",
                  "\r",
                  "?",
                  "!",
                  "(",
                  ")",
                  "{",
                  "}",
                  "]",
                  "[",
                  ":",
                  ";",
                  ",",
                  ".",
                  "="
                ],
                " "
              )
              |> String.downcase()
              |> String.split(" ")
              |> Enum.reduce(%{}, &str_reducer/2)
              |> Map.delete("")
              |> WordCountCollector.send_word_count()

              {num_all, num_unique} = UniqueArticleServer.num_of_articles()
              IO.write("\rProcessed articles: #{num_all}       Unique: #{num_unique}        ")
          end
      end
    else
      {:stop, :normal}
    end
  end

  def str_reducer(str, acc) do
    Map.update(acc, str, 1, &(&1 + 1))
  end
end
