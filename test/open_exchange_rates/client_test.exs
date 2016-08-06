defmodule OpenExchangeRates.ClientTest do
  use ExUnit.Case
 use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  test "it should get exchange rates" do
    use_cassette "client/get_latest" do
      assert  {:ok, %{"base" => "USD"}} = OpenExchangeRates.Client.get_latest
    end
  end
end
