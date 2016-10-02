use Mix.Config

config :ex_bots, ExBots.Astrobot,
  adapter: Hedwig.Adapters.Slack,
  token: "${SLACK_API_TOKEN}",
  rooms: ["#bottest"]

config :logger,
  level: :info
