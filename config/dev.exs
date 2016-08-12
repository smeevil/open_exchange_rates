use Mix.Config

config :open_exchange_rates,
  app_id: System.get_env("OER_APP_ID"),
  cache_time_in_minutes: 1440,
  auto_update: true

