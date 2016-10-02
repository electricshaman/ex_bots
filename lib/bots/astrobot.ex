defmodule ExBots.Astrobot do
  use Hedwig.Robot, otp_app: :ex_bots

  def handle_connect(state), do: {:ok, state}
  def handle_disconnect(_reason, state), do: {:reconnect, state}
  def handle_in(_msg, state), do: {:ok, state}
end
