defmodule OpenExchangeRates.Updater do
  @moduledoc """
  This module takes care of updating the cache with new conversion rates from openexchangerates.org and is for internal use only.
  """

  require Logger

  @update_interval_in_seconds 60

  def cache_file, do: Application.get_env(:open_exchange_rates, :cache_file) || (File.cwd! <> "/priv/latest.json")

  @doc false
  def start do
    load_data_from_disk
    check_for_update
    :ok
  end

  @doc false
  def check_for_update do
    cache_time = Application.get_env(:open_exchange_rates, :cache_time_in_minutes, 1440) * 60

    if OpenExchangeRates.Cache.cache_age >= cache_time, do: update
    Process.sleep(@update_interval_in_seconds * 1000)
    check_for_update
  end

  def load_data_from_disk do
    if File.exists?(cache_file()) do
      cached_at = File.lstat!(cache_file(), [time: :posix]).mtime
      cache_file()
      |> File.read!
      |> Poison.decode!
      |> update_cache!(cached_at)
      :ok
    else
      {:error, "could not find #{cache_file()} which you defined in your config"}
    end
  end

  def load_data_from_disk! do
    case load_data_from_disk do
      :ok -> :ok
      {:error, message} -> raise(message)
    end
  end

  defp write_to_disk!(data) do
    json = Poison.encode!(data)
    File.write!(cache_file(), json)
    data
  end

  defp update do
    Logger.info "OpenExchangeRates Updating Rates..."
    case OpenExchangeRates.Client.get_latest do
      {:ok, data} -> data |> write_to_disk! |> update_cache!
      {:error, message} -> {:error, message}
    end
  end

  defp update_cache!(data, cached_at \\ nil)
  defp update_cache!(%{"rates" => rates}, cached_at) do
    cached_at = cached_at || :os.system_time(:seconds)
    GenServer.call(OpenExchangeRates.Cache, {:update!, rates, cached_at})
  end
  defp update_cache!(data, _cached_at), do: raise "Data was corrupted ? #{inspect data}"

end
