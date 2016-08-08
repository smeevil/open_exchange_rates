defmodule OpenExchangeRates.Cache do
  @moduledoc """
  This module takes care of caching the currency rates and is for internal use only
  """
  use GenServer

  @cache_file Application.get_env(:open_exchange_rates, :cache_file) || (File.cwd! <> "/priv/latest.json")

  @doc false
  def start_link, do: GenServer.start_link(__MODULE__, nil, name: __MODULE__)

  @doc false
  def init(_opts) do
    {:ok, :ets.new(__MODULE__, [:set, :protected, :named_table])}
  end

  @doc false
  def file, do: @cache_file

  @doc false
  @spec rate_for_currency((String.t| Atom.t)) :: {:ok, Float.t} | {:error, String.t}
  def rate_for_currency(currency) when is_atom(currency), do: rate_for_currency(Atom.to_string(currency))
  def rate_for_currency(currency) when is_binary(currency) do
    case OpenExchangeRates.Cache |> :ets.lookup(String.upcase(currency)) do
      [] -> {:error, "unknown currency: #{currency}"}
      [{_, rate}] -> {:ok, rate}
    end
  end

  @doc false
  @spec currencies() :: [String.t]
  def currencies, do: OpenExchangeRates.Cache |> :ets.match({:"$1", :"_"}) |> List.flatten

  @doc false
  @spec update!([{String.t, Float.t}]) :: :ok
  def update!(rates) do
    GenServer.call(__MODULE__, {:update!, rates})
  end

  @doc false
  def handle_call({:update!, rates}, _caller, _state) do
    Enum.each(rates, fn {currency, rate} -> :ets.insert(__MODULE__, {currency, rate}) end)
    {:reply, :ok, rates}
  end
end
