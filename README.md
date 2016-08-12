# OpenExchangeRates
[![Build Status](https://semaphoreci.com/api/v1/smeevil/open_exchange_rates/branches/master/shields_badge.svg)](https://semaphoreci.com/smeevil/open_exchange_rates) [![Coverage Status](https://coveralls.io/repos/github/smeevil/open_exchange_rates/badge.svg?branch=master)](https://coveralls.io/github/smeevil/open_exchange_rates?branch=master) [![Deps Status](https://beta.hexfaktor.org/badge/all/github/smeevil/open_exchange_rates.svg)](https://beta.hexfaktor.org/github/smeevil/open_exchange_rates)

This Elixir library uses the [openexchangerates.org](https://openexchangerates.org) API to retieve the latest exchange rates.

At initialization of the library, it will use the latest exchange rates from a cache file. After initialization it will immediately try to get the latest exchange rates from openexchangerates.org. If this fails it will retry to get a new update every minute.

After a successful update, it will check every minute if the cache needs to be updated and fetches the new rates from openexchangerates.org. You can configure the cache time, which by default is 24 hours. Please take in account that every check will be taking credits from your API usage.

To be able to use this library you will need an API token from openexchangerates.org which you can get [here](https://openexchangerates.org/signup).

## Using it without an API key
This library will still function without a connection to the [openexchangerates.org](https://openexchangerates.org) API but please take into account the exchanges rates are coming from an (outdated) cache. This cache will be updated with every release of this library.
## Example usage
This library gives you the following functions :

- List available currencies
```elixir
OpenExchangeRates.available_currencies |> Enum.take(10)
["AWG", "NAD", "INR", "LAK", "BOB", "MOP", "QAR", "SDG", "TMT", "BRL"]
```

- Get the exchange rate for USD to an other currency
```elixir
OpenExchangeRates.rate_for_currency(:EUR)
{:ok, 0.902}
```

- Convert any currency to an other
```elixir
OpenExchangeRates.convert(100.00, :EUR, :GBP)
{:ok, 84.81186252771619}

OpenExchangeRates.convert!(100.00, :EUR, :GBP)
84.81186252771619
```

- Convert cents in any currency to an other
```elixir
OpenExchangeRates.convert_cents(100, :GBP, :AUD)
{:ok, 172}

OpenExchangeRates.convert_cents!(100, :GBP, :AUD)
172
```

- convert a currency and return a properly formatted string for that currency
```elixir
OpenExchangeRates.convert_and_format(1234, :EUR, :AUD)
{:ok, "A$1,795.10"}

OpenExchangeRates.convert_and_format!(1234, :EUR, :AUD)
"A$1,795.10"
```

- convert cents and return a properly formatted string for that currency
```elixir
OpenExchangeRates.convert_cents_and_format(1234567, :EUR, :NOK)
{:ok, "116.495,78NOK"}

OpenExchangeRates.convert_cents_and_format!(1234567, :EUR, :NOK)
"116.495,78NOK"
```

- Get the age of the cache in seconds
```elixir
OpenExchangeRates.cache_age
25341
```
## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `open_exchange_rates` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:open_exchange_rates, "~> 0.1.0"}]
    end
    ```

  2. Ensure `open_exchange_rates` is started before your application:

    ```elixir
    def application do
      [applications: [:open_exchange_rates]]
    end
    ```

## Configuration

Please add the following config to your config.exs
```elixir
config :open_exchange_rates,
  app_id: "MY API KEY",
  cache_time_in_minutes: 1440 #24 hours
```


## Testing the library
Before you run the tests, please make sure to set the OER_APP_ID environment to you app_id key.

