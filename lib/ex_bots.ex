defmodule ExBots do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(ExBots.Brain, []),
      worker(ExBots.Astrobot, []),
    ]

    opts = [strategy: :one_for_one, name: ExBots.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
