defmodule ExBots.Mixfile do
  use Mix.Project

  def project do
    [app: :ex_bots,
     version: "0.2.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    [applications: [:logger, :hedwig, :hedwig_slack, :httpoison],
     mod: {ExBots, []}]
  end

  defp deps do
    [{:hedwig, github: "hedwig-im/hedwig", ref: "ea022ef"},
     {:hedwig_slack, github: "hedwig-im/hedwig_slack", ref: "7991e16"},
     {:httpoison, "~> 0.9.0"},
     {:poison, "~> 2.0"},
     {:distillery, "~> 0.9"}]
  end

end
