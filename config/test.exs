use Mix.Config

config :exvcr, [
  vcr_cassette_library_dir: "fixture/vcr_cassettes",
  custom_cassette_library_dir: "fixture/custom_cassettes",
  filter_sensitive_data: [
    [pattern: "app_id=.*", placeholder: "app_id=APP_ID_PLACEHOLDER"]
  ],
  filter_url_params: false,
  response_headers_blacklist: []
]

config :open_exchange_rates,
  app_id: System.get_env("OER_APP_ID"),
  cache_time_in_minutes: 1440,
  cache_file: File.cwd! <> "/fixture/exchange_data.json",
  auto_update: false
