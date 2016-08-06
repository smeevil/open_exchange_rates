defmodule OpenExchangeRatesTest do
  use ExUnit.Case
  doctest OpenExchangeRates

  test "currencies" do
    assert 172 = OpenExchangeRates.available_currencies |> Enum.count
  end

  test "convert usd to eur" do
    assert  {:ok, 90} = OpenExchangeRates.convert_cents(100, :USD, :EUR)
  end

  test "convert eur to usd" do
    assert  {:ok, 111} = OpenExchangeRates.convert_cents(100, :EUR, :USD)
  end

  test "convert eur to gbp" do
    assert  {:ok, 85} = OpenExchangeRates.convert_cents(100, :EUR, :GBP)
  end

  test "convert gbp to eur" do
    assert  {:ok, 118} = OpenExchangeRates.convert_cents(100, :GBP, :EUR)
  end
end
