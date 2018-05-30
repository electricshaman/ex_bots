defmodule ExBots do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(ExBots.Brain, []),
      worker(ExBots.Astrobot, []),
      worker(ExBots.RSS.Collector, ["#bottest", "https://www.universetoday.com/feed/", :ets.new(nil, [:public])], id: UTCollector),
      worker(ExBots.RSS.Collector, ["#bottest", "https://spaceflightnow.com/feed/", :ets.new(nil, [:public])], id: SFNCollector),
      worker(ExBots.RSS.Collector, ["#bottest", "https://phys.org/rss-feed/space-news/", :ets.new(nil, [:public])], id: PhysCollector)
    ]

    opts = [strategy: :one_for_one, name: ExBots.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
