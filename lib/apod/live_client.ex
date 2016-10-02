defmodule Apod.LiveClient do
  require Logger

  @behaviour  Apod.Client
  @base_url   Application.get_env(:ex_bots, :apod_base_url)

  def today do
    api_key = Application.get_env(:ex_bots, :nasa_api_key)
    url = @base_url <> api_key
    Logger.debug "Hitting #{url}"

    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        case Poison.decode(body) do
          {:ok, decoded} -> {:ok, decoded}
          other -> {:error, other}
        end
      {:ok, %HTTPoison.Response{status_code: status_code}} ->
        {:error, {:bad_status_code, status_code}}
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end
end
