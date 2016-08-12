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
    assert  {:ok, 1.1790803434757773} = OpenExchangeRates.convert(1, "GBP", "EUR")
    assert  {:ok, 1.1790803434757773} = OpenExchangeRates.convert(1.0, "GBP", "EUR")
    assert  {:ok, 1.1790803434757773} = OpenExchangeRates.convert(1.0, "gbp", "eur")
    assert  {:ok, 1.1790803434757773} = OpenExchangeRates.convert(1.0, :gbp, :eur)
    assert  {:ok, 1.1790803434757773} = OpenExchangeRates.conversion_rate(:gbp, :eur)
    assert  {:ok, 1.1790803434757773} = OpenExchangeRates.conversion_rate("gbp", "eur")
    assert  {:ok, 1.1790803434757773} = OpenExchangeRates.conversion_rate("GBP", "EUR")
  end

  test "it should return the cache age" do
    assert is_integer(OpenExchangeRates.cache_age)
  end

  test "it should return an error when formatting an unknown currency" do
    assert {:error, "unknown currency: BLA"} = OpenExchangeRates.convert_and_format(123456789, :EUR, :BLA)
  end
  test "it should convert and return a formatted string" do
    assert {:ok, "£104,706,002.17"} = OpenExchangeRates.convert_and_format(123456789, :EUR, :GBP)
    assert "£104,706,002.17" = OpenExchangeRates.convert_and_format!(123456789, :EUR, :GBP)

    assert {:ok, "£1,047,060.02"} = OpenExchangeRates.convert_cents_and_format(123456789, :EUR, :GBP)
    assert "£1,047,060.02" = OpenExchangeRates.convert_cents_and_format!(123456789, :EUR, :GBP)
  end

  test "it show raise when convert! with unknown currency" do
    assert_raise RuntimeError, "unknown currency: BLA", fn -> OpenExchangeRates.convert!(100, :EUR, :BLA) end
  end

  test "it show raise when convert_cents! with unknown currency" do
    assert_raise RuntimeError, "unknown currency: BLA", fn -> OpenExchangeRates.convert_cents!(100, :EUR, :BLA) end
  end

  test "it show raise when convert_and_format! with unknown currency" do
    assert_raise RuntimeError, "unknown currency: BLA", fn -> OpenExchangeRates.convert_and_format!(100, :EUR, :BLA) end
  end

  test "it show raise when convert_cents_and_format! with unknown currency" do
    assert_raise RuntimeError, "unknown currency: BLA", fn -> OpenExchangeRates.convert_cents_and_format!(100, :EUR, :BLA) end
  end
end
