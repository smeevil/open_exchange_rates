defmodule OpenExchangeRates.CacheTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

#  test "it should return a timestamp of the cache" do
#    assert {:ok, 1470489905} = OpenExchangeRates.Cache.timestamp
#  end

#  test "it should get exchange rates" do
#    use_cassette "client/get_latest" do
#      assert {:ok, %{"timestamp" => 1470486903}} = OpenExchangeRates.Cache.update
#    end
#  end
end
