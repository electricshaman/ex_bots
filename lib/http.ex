defmodule ExBots.HTTP do
  require Logger

  def get(url, body_fun) do
    Logger.debug("Hitting #{url}")

    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        body_fun.(body)

      {:ok, %HTTPoison.Response{status_code: status_code}} ->
        Logger.warn("Bad response status code: #{status_code}")
        {:error, {:bad_status_code, status_code}}

      {:error, %HTTPoison.Error{reason: reason}} ->
        Logger.warn("Other HTTP error: #{inspect(reason)}")
        {:error, reason}
    end
  end
end
