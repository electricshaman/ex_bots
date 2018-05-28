defmodule ExBots.Astrobot do
  use Hedwig.Robot, otp_app: :ex_bots

  require Logger

  def get_adapter() do
    GenServer.call(whereis(), :get_adapter)
  end

  def send_to_channel(channel, text) do
    chid = get_channel_id(channel)

    unless is_nil(chid) do
      Hedwig.Robot.send(whereis(), %Hedwig.Message{type: "message", room: chid, text: text})
    end
  end

  def get_channel_id(name) do
    ExBots.Astrobot.get_channels()
    |> Map.get(name)
  end

  def get_channels() do
    adapter_pid = get_adapter()
    # This is bad.  I know.
    adapter_state = :sys.get_state(adapter_pid)
    Enum.map(adapter_state.channels, fn {k, v} -> {"#" <> v["name"], k} end) |> Map.new()
  end

  def whereis() do
    :global.whereis_name("astrobot")
  end

  def handle_connect(%{name: name} = state) do
    Logger.debug("Bot name: #{name}")

    if :undefined == :global.whereis_name(name) do
      :yes = :global.register_name(name, self())
    end

    {:ok, state}
  end

  def handle_disconnect(_reason, state), do: {:reconnect, state}

  def handle_in(_msg, state) do
    {:ok, state}
  end

  def handle_call(:get_adapter, _from, state) do
    {:reply, state.adapter, state}
  end
end
