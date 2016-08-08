defmodule OpenExchangeRates.Updater do
  @moduledoc """
  This module takes care of updating the cache with new conversion rates from openexchangerates.org and is for internal use only.
  """

  require Logger
  use GenServer

  @update_interval_in_seconds 60

  @doc false
  def start_link do
    {:ok, pid} = GenServer.start_link(__MODULE__, nil, name: __MODULE__)
    maybe_load_data_from_disk
    check_for_update
    {:ok, pid}
  end

  @doc false
  def init(_opts) do
    :timer.apply_interval(:timer.seconds(@update_interval_in_seconds), __MODULE__, :check_for_update, [])
    {:ok, %{last_updated_at: 0}}
  end

  @doc false
  def check_for_update do
    last_updated_at = GenServer.call(__MODULE__, {:last_updated_at})
    diff =  (:os.system_time(:seconds) - last_updated_at) / 60
    cache_time = Application.get_env(:open_exchange_rates, :cache_time_in_minutes, 1440)
    if diff >= cache_time, do: update
  end

  defp maybe_load_data_from_disk do
    case File.exists?(OpenExchangeRates.Cache.file) do
      true -> OpenExchangeRates.Cache.file |> File.read! |> Poison.decode! |> update_cache!
      false -> update
    end
  end

  defp write_to_disk!(data) do
    GenServer.call(__MODULE__, {:set_last_updated_at, :os.system_time(:seconds)})
    json = Poison.encode!(data)
    File.write!(OpenExchangeRates.Cache.file, json)
    data
  end

  defp update do
    Logger.info "OpenExchangeRates Updating Rates..."
    case OpenExchangeRates.Client.get_latest do
      {:ok, data} -> data |> write_to_disk! |> update_cache!
      {:error, message} -> {:error, message}
    end
  end

  defp update_cache!(%{"rates" => rates}), do: GenServer.call(OpenExchangeRates.Cache, {:update!, rates})
  defp update_cache!(data), do: raise "Data was corrupted ? #{inspect data}"

  def handle_call({:last_updated_at}, _caller, state) do
    timestamp = Map.get(state, :last_updated_at, 0)
    {:reply, timestamp, state}
  end

  def handle_call({:set_last_updated_at, timestamp}, _caller, state) do
    state = Map.put(state, :last_updated_at, timestamp)
    {:reply, :ok, state}
  end

end
