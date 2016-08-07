defmodule OpenExchangeRates do
  @moduledoc """
  This module contains all the helper methods for converting currencies
  """
  use Application

  @doc false
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(OpenExchangeRates.Cache, []),
      worker(OpenExchangeRates.Updater, []),
    ]

    opts = [strategy: :one_for_one, name: OpenExchangeRates.Supervisor]
    Supervisor.start_link(children, opts)
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
      {:ok, rate_to_usd} <- OpenExchangeRates.Cache.rate_for_currency(from),
      {:ok, rate} <- OpenExchangeRates.Cache.rate_for_currency(to) \
    do
      usd = value / rate_to_usd
      converted = usd * rate
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
  Get the conversion rate for a given currency to USD"

  ## Example

      iex> OpenExchangeRates.rate_for_currency(:EUR)
      {:ok, 0.902}

  """
  @spec rate_for_currency((String.t| Atom.t)) :: {:ok, Float.t} | {:error, String.t}
  def rate_for_currency(currency), do: OpenExchangeRates.Cache.rate_for_currency(currency)
end
