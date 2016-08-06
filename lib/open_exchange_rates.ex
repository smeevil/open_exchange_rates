defmodule OpenExchangeRates do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(OpenExchangeRates.Cache, []),
    ]

    opts = [strategy: :one_for_one, name: OpenExchangeRates.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def available_currencies, do: GenServer.call(OpenExchangeRates.Cache, {:currencies})
  def convert_cents(cents, from, to), do: GenServer.call(OpenExchangeRates.Cache, {:convert_cents, cents, from, to})
end
