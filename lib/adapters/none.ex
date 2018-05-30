defmodule ExBots.Adapters.None do
  use Hedwig.Adapter

  def init(args) do
    {:ok, args}
  end
end
