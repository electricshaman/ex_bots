defmodule ExBots.RSS.Collector do
  alias ExBots.Astrobot

  require Logger
  require EEx

  EEx.function_from_file(:def, :format_entry, "lib/rss/entry.eex", [:assigns])

  @entry_days_valid 30
  @bad_status_code_responses [
    "I'm drunk.",
    "I have no idea what's going on right now.",
    "Strange things are afoot at the Circle K.",
    "Carl Sagan is my hero.",
    "Guys",
    "I believe that you can find happiness in slavery.",
    "I'm sorry, Dave. I'm afraid I can't do that.",
    "WTF?",
    ":boom:",
    ":joy:"
  ]

  def start_link(channel, feed_url, table) do
    GenServer.start_link(__MODULE__, [channel, feed_url, table])
  end

  def init([channel, feed_url, table]) do
    state = %{channel: channel, feed_url: feed_url, table: table}
    Logger.debug("Starting up RSS collector worker with state #{inspect(state)}")
    Process.send_after(self(), :collect, Enum.random(100..1000))
    {:ok, state}
  end

  def handle_info(:collect, %{feed_url: url, channel: chan, table: tid} = state) do
    first_run? = is_first_run?(tid)

    # Hedwig's Robot behaviour hijacks start_link/init so we have to wait for its handle_connect callback
    # to fire which registers the bot globally, allowing us to find its PID easily.
    # TODO: Consider switching to GenStateMachine to manage this.
    _ = wait_for_bot()

    with {:ok, entries} <- get_entries(url) do
      Enum.each(entries, fn entry ->
        is_new_entry? = :ets.insert_new(tid, {entry.id, entry})

        if is_new_entry? && !first_run? do
          text = Map.from_struct(entry) |> format_entry()
          Astrobot.send_to_channel(chan, text)
        end
      end)
    else
      {:error, {:bad_status_code, code}} ->
        Logger.error("Bad status code returned while fetching RSS feed at #{url}: #{code}")
        Astrobot.send_to_channel(chan, Enum.random(@bad_status_code_responses))

      other ->
        Logger.error("Something happened: #{inspect(other)}")
        Astrobot.send_to_channel(chan, "¯\\_(ツ)_/¯")
    end

    _ = prune_entry_history(tid)

    # Run the collection again after a random time between 60 and 90 minutes.
    Process.send_after(self(), :collect, :timer.minutes(Enum.random(60..90)))

    {:noreply, state}
  end

  defp prune_entry_history(tid) do
    expired_entries_in_table(tid)
    |> Enum.each(fn {id, key} ->
      Logger.debug("Flushing entry from history with ID #{inspect(id)}")
      :ets.delete(tid, id)
    end)
  end

  defp expired_entries_in_table(tid, num_days_valid \\ @entry_days_valid) do
    :ets.tab2list(tid)
    |> Enum.filter(fn {_id, entry} ->
      days_old(entry) > num_days_valid
    end)
  end

  defp days_old(%{updated: ts}) do
    with {:ok, parsed} <- Timex.parse(ts, "{RFC1123}") do
      Timex.diff(Timex.now(), parsed, :days)
    end
  end

  defp days_old(_other) do
    {:error, :missing_timestamp}
  end

  defp get_entries(url) do
    ExBots.HTTP.get(url, fn body ->
      with {:ok, feed, _} = FeederEx.parse(body) do
        {:ok, feed.entries}
      end
    end)
  end

  defp is_first_run?(table) do
    ets_size(table) == 0
  end

  defp ets_size(table) do
    info = :ets.info(table)
    Keyword.get(info, :size)
  end

  defp wait_for_bot() do
    case Astrobot.whereis() do
      :undefined ->
        :timer.sleep(1)
        wait_for_bot()

      pid ->
        pid
    end
  end
end
