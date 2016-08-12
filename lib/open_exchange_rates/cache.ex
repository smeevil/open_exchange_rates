defmodule OpenExchangeRates.Cache do
  @moduledoc """
  This module takes care of caching the currency rates and is for internal use only
  """
  use GenServer


  @doc false
  def start_link(configuration_status) do
    GenServer.start_link(__MODULE__, configuration_status, name: __MODULE__)
  end

  @doc false
  def init(configuration_status) do
    ets = :ets.new(__MODULE__, [:set, :protected, :named_table])
    start_updater(configuration_status)
    {:ok, %{ets: ets, cached_at: 0}}
  end

  @doc """
  Get the age of the cache in seconds
  """
  @spec cache_age() :: Integer.t
  def cache_age do
    cached_at = GenServer.call(__MODULE__, {:cached_at})
    :os.system_time(:seconds) - cached_at
  end

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
  @spec update!([{String.t, Float.t}], Integer.t) :: :ok
  def update!(rates, cached_at) do
    GenServer.call(__MODULE__, {:update!, rates, cached_at})
  end

  @doc false
  def handle_call({:update!, rates, cached_at}, _caller, %{ets: ets} = state) do
    Enum.each(rates, fn {currency, rate} -> :ets.insert(ets, {currency, rate}) end)
    state = Map.put(state, :cached_at, cached_at)
    {:reply, :ok, state}
  end

  @doc false
  def handle_call({:cached_at}, _caller, %{cached_at: cached_at} = state), do: {:reply, cached_at, state}


  def start_updater(configuration_status) do
    function = case configuration_status do
      :disable_updater -> &OpenExchangeRates.Updater.load_data_from_disk!/0
      :missing_key -> &OpenExchangeRates.Updater.load_data_from_disk!/0
      _other -> &OpenExchangeRates.Updater.start/0
    end
    spawn_link(function)
  end
end
