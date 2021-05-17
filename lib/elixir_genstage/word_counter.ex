defmodule ElixirGenstage.WordCounter do
  def start_link(event) do
    Task.start_link(fn ->
      WordCountCollector.send_word_count(count_words(event))
    end)
  end

  def count_words(article_name) do
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
        %{}

      {:ok, %{body: res}} ->
        {:ok, %{"query" => %{"pages" => data}}} =
          res
          |> Poison.decode()

        data
        |> Map.to_list()
        |> Enum.filter(fn {id, _} -> id != "-1" end)
        |> Enum.map(fn {_, %{"extract" => res}} -> res end)
        |> Enum.reduce("", &(&1 <> &2))
        |> String.replace(
          ["\n", "\"", "\r", "?", "!", "(", ")", "{", "}", "(", ")", ":", ";", ",", ".", "="],
          " "
        )
        |> String.downcase()
        |> String.split(" ")
        |> List.flatten()
        |> Enum.reduce(%{}, &str_reducer/2)
        |> Map.delete("")
    end
  end

  def str_reducer(str, acc) do
    Map.update(acc, str, 1, &(&1 + 1))
  end
end
