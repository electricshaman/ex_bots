defmodule ExBots.Mixfile do
  use Mix.Project

  def project do
    [app: :ex_bots,
     version: "0.2.0",
     elixir: "~> 1.5",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {ExBots, []}
    ]
  end

  defp deps do
    [{:hedwig, "~> 1.0"},
     {:hedwig_slack, "~> 1.0"},
     {:httpoison, "~> 1.1"},
     {:poison, "~> 3.0"},
     {:distillery, "~> 0.9"},
     {:timex, "~> 3.1"},
     {:bloomex, "~> 1.0"},
     {:feeder_ex, "~> 1.1"}]
  end
end
