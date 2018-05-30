defmodule ExBots.Responders.Apod do
  use Hedwig.Responder
  alias ExBots.Brain
  require EEx
  require Logger

  EEx.function_from_file(:def, :apod_response, "lib/responders/apod.eex", [:assigns])

  @usage """
  apod - Display today's Astronomy Picture of the Day.
  """
  hear ~r/\bapod\b/i, msg, %{client: client, rate_limit_sec: rate} do
    if respond?(rate) do
      case client.today do
        {:ok, result} ->
          # Apod.Picture isn't enumerable so we convert it to a map first so EEx can assign its fields to the template.
          result_map = Map.from_struct(result)
          send(msg, apod_response(result_map))

        {:error, {:bad_status_code, code}} ->
          reply(msg, "Weird: #{code}")

        {:error, _other} ->
          reply(msg, "Get it yourself.")
      end

      responded()
    end
  end

  def respond?(rate_limit_sec) do
    case Brain.remember(:last_response) do
      nil -> true
      last_response -> System.monotonic_time(:seconds) - last_response >= rate_limit_sec
    end
  end

  def responded do
    :ok = Brain.memorize(:last_response, System.monotonic_time(:seconds))
  end
end
