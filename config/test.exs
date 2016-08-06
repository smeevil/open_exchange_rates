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
