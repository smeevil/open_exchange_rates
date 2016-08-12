## 0.3.0 (2016-08-12)
  - The updater is no longer a genserver but a recursive call which is started and linked by the cache
  - Cache can now return a cache age and the updater will properly honer th cache time.
  - When starting the app, it will check the cache age of the cache file, and use that if its still valid, otherwise do a direct update
  - Added bang methods
  - Added methods to return a formatted currency string

## 0.2.0 (2016-08-08)
  - OpenExchangeRates.rate_for_currency/1 is now OpenExchangeRates.conversion_rate/2
  - Config now accepts two new settings
    - cache_file: "/path/to/cache.json"
    - auto_update: true
  - Supervisor now is a one_for_all, in stead of one_for_one, this makes sure that the updater and cache are linked to each other.
  - bumped Credo version

## 0.1.0 (2016-08-07)

  - Initial release
