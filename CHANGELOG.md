## 0.2.0 (2016-08-08)
  - OpenExchangeRates.rate_for_currency/1 is now OpenExchangeRates.conversion_rate/2
  - Config now accepts two new settings
    - cache_file: "/path/to/cache.json"
    - auto_update: true
  - Supervisor now is a one_for_all, in stead of one_for_one, this makes sure that the updater and cache are linked to each other.
  - bumped Credo version

## 0.1.0 (2016-08-07)

  - Initial release
