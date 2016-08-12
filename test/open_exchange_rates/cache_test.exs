defmodule OpenExchangeRates.CacheTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  doctest OpenExchangeRates.Cache

  test "it should an error for an unknown currency" do
    assert  {:error, "unknown currency: BLA"} == OpenExchangeRates.Cache.rate_for_currency("BLA")
  end

  test "it should return a rate for a currency" do
    assert  {:ok, 0.902} == OpenExchangeRates.Cache.rate_for_currency("EUR")
  end

  test "it should update its rates" do
    {:ok, rate} = OpenExchangeRates.Cache.rate_for_currency("EUR")
    assert 0.902 == rate
    OpenExchangeRates.Cache.update!(%{"EUR" => 0.1}, :os.system_time(:seconds))
    assert {:ok, 0.1} == OpenExchangeRates.Cache.rate_for_currency("EUR")

    #reset to original value
    OpenExchangeRates.Cache.update!(%{"EUR" => rate}, :os.system_time(:seconds))
  end
end
