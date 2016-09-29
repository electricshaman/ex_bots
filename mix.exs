defmodule ExBots.Mixfile do
  use Mix.Project

  def project do
    [app: :ex_bots,
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    [applications: [:logger, :hedwig, :hedwig_slack],
     mod: {ExBots, []}]
  end

  defp deps do
    [{:hedwig, github: "hedwig-im/hedwig", ref: "ea022ef"},
     {:hedwig_slack, github: "hedwig-im/hedwig_slack", ref: "7991e16"}]
  end

end
