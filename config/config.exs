use Mix.Config

config :ex_bots, ExBots.Astrobot,
  adapter: Hedwig.Adapters.Console,
  name: "astrobot",
  aka: "/",
  responders: [
    {Hedwig.Responders.Help, []},
    {ExBots.Responders.Apod, [client: Apod.LiveClient, rate_limit_sec: 3600]}
  ]

config :ex_bots,
  nasa_api_key: "${NASA_API_KEY}",
  apod_base_url: "https://api.nasa.gov/planetary/apod?api_key="

import_config "#{Mix.env}.exs"
