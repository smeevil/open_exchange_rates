# OpenExchangeRates

**TODO: Add description**

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

Please make sure to set the OER_APP_ID environment to you app_id key.
