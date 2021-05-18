# Elixir GenStage Project

Miniproject on Elixir GenStage created by Karol Wilk.

# Usage

I tested and launched the app in interactive mode via `iex -S mix`.

## Useful callbacks

- ElixirGenstageProject.start/0 - starts the application, asks for timeframe and computes.

- ElixirGenstageProject.stop/0 - stops the top level supervisor.

- WordCountCollector.get_word_count/0 - gets the current map of word counts.

- UniqueArticleServer.num_of_articles/0 - gets `{num_all_articles, num_unique_articles}`