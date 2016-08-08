defmodule OpenExchangeRates do
  @moduledoc """
  This module contains all the helper methods for converting currencies
  """
  use Application
  require Logger

  @doc false
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    configuration_status = check_configuration

    children = [
      worker(OpenExchangeRates.Cache, []),
    ]

    children = case configuration_status do
      :ok -> children ++ [worker(OpenExchangeRates.Updater, [])]
      _ -> children
    end

    opts = [strategy: :one_for_all, name: OpenExchangeRates.Supervisor]
    {:ok, pid} = Supervisor.start_link(children, opts)

    case configuration_status do
      :disable_updater -> load_data_from_file
      :missing_key -> load_data_from_file
      _ -> nil
    end

    {:ok, pid}
  end

  @doc"""
  Returns a list of all available currencies.

  ## example

      iex> OpenExchangeRates.available_currencies |> Enum.take(10)
      ["AWG", "NAD", "INR", "LAK", "BOB", "MOP", "QAR", "SDG", "TMT", "BRL"]

  """
  @spec available_currencies() :: [String.t]
  def available_currencies, do: OpenExchangeRates.Cache.currencies

  @doc"""
  Will convert a price from once currency to another

  ## example

      iex> OpenExchangeRates.convert(100.00, :EUR, :GBP)
      {:ok, 84.81186252771619}

  """
  @spec convert(Float.t, (String.t | Atom.t), (String.t | Atom.t)) :: {:ok, Float.t} | {:error, String.t}
  def convert(value, from, to) when is_float(value) do
    with \
      {:ok, rate_from} <- OpenExchangeRates.Cache.rate_for_currency(from),
      {:ok, rate_to} <- OpenExchangeRates.Cache.rate_for_currency(to) \
    do
      rate_usd = value / rate_from
      converted = rate_usd * rate_to
      {:ok, converted}
    else
      error -> error
    end
  end

  @doc"""
  Will convert cents from once currency to another

  ## example

      iex> OpenExchangeRates.convert_cents(100, :GBP, :AUD)
      {:ok, 172}

  """
  @spec convert_cents(Integer.t, (String.t | Atom.t), (String.t | Atom.t)) :: {:ok, Integer.t} | {:error, String.t}
  def convert_cents(value, from, to) when is_integer(value) do
    case convert(value/100, from, to) do
      {:ok, result} -> {:ok, Kernel.round(result * 100)}
      error -> error
    end
  end

  @doc """
  Get the conversion rate for a between two currencies"

  ## Example

      iex> OpenExchangeRates.conversion_rate(:EUR, :GBP)
      {:ok, 0.8481186252771619}

  """
  @spec conversion_rate((String.t| Atom.t), (String.t| Atom.t)) :: {:ok, Float.t} | {:error, String.t}
  def conversion_rate(from, to) when is_binary(from) and is_binary(to), do: conversion_rate(String.to_atom(from), String.to_atom(to))
  def conversion_rate(from, to), do: convert(1.0, from, to)

  defp check_configuration do
    cond do
      Application.get_env(:open_exchange_rates, :auto_update) == false -> :disable_updater
      Application.get_env(:open_exchange_rates, :app_id) == nil -> config_error_message; :missing_key
      true -> :ok
    end
  end

  defp config_error_message do
    Logger.warn ~s[
OpenExchangeRates :

No App ID provided.

Please check if your config.exs contains the following :
  config :open_exchange_rates,
    app_id: "MY_OPENEXCHANGE_RATES_ORG_API_KEY",
    cache_time_in_minutes: 1440,
    cache_file: File.cwd! <> "/priv/exchange_rate_cache.json",
    auto_update: true

If you need an api key please sign up at https://openexchangerates.org/signup

This module will continue to function but will use (outdated) cached exchange rates data...
    ]
  end

  defp load_data_from_file do
    if File.exists?(OpenExchangeRates.Cache.file) do
      OpenExchangeRates.Cache.file
      |> File.read!
      |> Poison.decode!
      |> Map.fetch!("rates")
      |> OpenExchangeRates.Cache.update!
    end
  end
end
