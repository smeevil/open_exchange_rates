defmodule OpenExchangeRatesTest do
  use ExUnit.Case
  doctest OpenExchangeRates

  test "currencies" do
    assert 172 = OpenExchangeRates.available_currencies |> Enum.count
  end

  test "convert non existing currency" do
    assert {:error, "unknown currency: BLA"} = OpenExchangeRates.convert_cents(100, :BLA, :EUR)
  end

  test "get conversion rate between two currencies" do
    {:ok, 0.8481186252771619} = OpenExchangeRates.conversion_rate(:EUR, :GBP)
  end

  test "convert usd to eur" do
    assert  {:ok, 90} = OpenExchangeRates.convert_cents(100, :USD, :EUR)
    assert  {:ok,  0.902} = OpenExchangeRates.convert(1.0, :USD, :EUR)
  end

  test "convert eur to usd" do
    assert  {:ok, 111} = OpenExchangeRates.convert_cents(100, :EUR, :USD)
    assert  {:ok, 1.1086474501108647} = OpenExchangeRates.convert(1.0, :EUR, :USD)
  end

  test "convert eur to gbp" do
    assert  {:ok, 85} = OpenExchangeRates.convert_cents(100, :EUR, :GBP)
    assert   {:ok, 0.8481186252771619} = OpenExchangeRates.convert(1.0, :EUR, :GBP)
  end

  test "convert gbp to eur" do
    assert  {:ok, 118} = OpenExchangeRates.convert_cents(100, :GBP, :EUR)
    assert  {:ok, 1.1790803434757773} = OpenExchangeRates.convert(1.00, :GBP, :EUR)
  end


  test "sanitize user input" do
    assert  {:ok, 118} = OpenExchangeRates.convert_cents(100, "GBP", "EUR")
    assert  {:ok, 118} = OpenExchangeRates.convert_cents(100, "gbp", "eur")
    assert  {:ok, 118} = OpenExchangeRates.convert_cents(100, :gbp, :eur)
    assert  {:ok, 1.1790803434757773} = OpenExchangeRates.convert(1.0, "GBP", "EUR")
    assert  {:ok, 1.1790803434757773} = OpenExchangeRates.convert(1.0, "gbp", "eur")
    assert  {:ok, 1.1790803434757773} = OpenExchangeRates.convert(1.0, :gbp, :eur)
  end

end
