defmodule ExBots.RSS.Collector do
  alias ExBots.Astrobot

  require Logger
  require EEx

  EEx.function_from_file(:def, :format_entry, "lib/rss/entry.eex", [:assigns])

  @entry_days_valid 30
  @datetime_formats [
    "{RFC1123}",
    "{WDshort}, {D} {Mfull} {YYYY} {h24}:{m}:{s} {Zabbr}"
  ]

  def start_link(channel, feed_url, table) do
    GenServer.start_link(__MODULE__, [channel, feed_url, table])
  end

  def init([channel, feed_url, table]) do
    init_state = %{channel: channel, feed_url: feed_url, table: table}
    Logger.debug("Starting up RSS collector worker with state #{inspect(init_state)}")
    Process.send_after(self(), :collect, Enum.random(100..1000))
    {:ok, init_state}
  end

  def handle_info(:collect, %{feed_url: url, channel: chan, table: tid} = state) do
    first_run? = is_first_run?(tid)

    # Hedwig's Robot behaviour hijacks start_link/init so we have to wait for its handle_connect callback
    # to fire which registers the bot globally, allowing us to find its PID easily (so we can push messages to it).
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
        Astrobot.send_to_channel(chan, bad_status_code_response())

      other ->
        Logger.error(
          "Something bad happened while fetching RSS feed at #{url}: #{inspect(other)}"
        )

        Astrobot.send_to_channel(chan, unknown_error_response())
    end

    _ = prune_entry_history(tid)

    # Run the collection again after a random time between 60 and 90 minutes.
    Process.send_after(self(), :collect, :timer.minutes(Enum.random(60..90)))

    {:noreply, state}
  end

  defp bad_status_code_response() do
    Enum.random([
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
    ])
  end

  defp unknown_error_response() do
    "¯\\_(ツ)_/¯"
  end

  defp prune_entry_history(tid) do
    expired_entries_in_table(tid)
    |> Enum.each(fn {id, _entry} ->
      Logger.debug("Flushing entry from history with ID #{inspect(id)}")
      :ets.delete(tid, id)
    end)
  end

  defp expired_entries_in_table(tid, num_days_valid \\ @entry_days_valid) do
    :ets.tab2list(tid)
    |> Enum.filter(fn {_id, entry} ->
      case days_old(entry) do
        {:ok, days} ->
          days >= num_days_valid

        other ->
          # If datetime parsing fails, purge the entry.
          Logger.error("Datetime parsing failed: #{inspect(other)} for entry: #{inspect(entry)}")
          true
      end
    end)
  end

  defp days_old(%{updated: ts}) do
    with {:ok, datetime} <- parse_datetime(ts, @datetime_formats) do
      {:ok, Timex.diff(Timex.now(), datetime, :days)}
    end
  end

  defp days_old(_other) do
    {:error, :bad_entry}
  end

  defp parse_datetime(datetime_string, [format | rest]) do
    with {:ok, datetime} <- Timex.parse(datetime_string, format) do
      {:ok, datetime}
    else
      {:error, reason} ->
        Logger.warn(
          "Wrong format #{format} for datetime string #{datetime_string}, skipping. Error: #{
            inspect(reason)
          }"
        )

        parse_datetime(datetime_string, rest)
    end
  end

  defp parse_datetime(_datetime_string, []) do
    {:error, :unknown_datetime}
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
