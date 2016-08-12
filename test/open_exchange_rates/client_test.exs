defmodule OpenExchangeRates.ClientTest do
  use ExUnit.Case
 use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  test "it should get exchange rates" do
    use_cassette "client/get_latest" do
      assert  {:ok, %{"base" => "USD"}} = OpenExchangeRates.Client.get_latest
    end
  end

  test "it should handle api errors" do
    use_cassette "client/api_error" do
      assert  {:error, "Something went horribly wrong!"} == OpenExchangeRates.Client.get_latest
    end
  end

  test "it should handle corrupt json" do
    use_cassette "client/corrupt" do
      assert {:error, "Could not parse the JSON : \"{\\n  \\\"corrupt\""} == OpenExchangeRates.Client.get_latest
    end
  end


  test "it should handle no connection" do
    use_cassette "client/no_connection" do
      assert  {:error, %HTTPoison.Error{id: nil, reason: "econnrefused"}} == OpenExchangeRates.Client.get_latest
    end
  end
end
