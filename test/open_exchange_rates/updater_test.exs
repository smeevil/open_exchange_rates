defmodule OpenExchangeRates.UpdaterTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  test "it should return an error when it could not load the file from disk" do
    cache_file = Application.get_env(:open_exchange_rates, :cache_file)
    Application.put_env(:open_exchange_rates, :cache_file, "404.json")
    assert  {:error, "could not find 404.json which you defined in your config"} == OpenExchangeRates.Updater.load_data_from_disk
    #reset
    Application.put_env(:open_exchange_rates, :cache_file, cache_file)
  end

  test "it raise when it could not load the file from disk and called with a bang" do
    cache_file = Application.get_env(:open_exchange_rates, :cache_file)
    Application.put_env(:open_exchange_rates, :cache_file, "404.json")

    assert_raise RuntimeError, "could not find 404.json which you defined in your config", &OpenExchangeRates.Updater.load_data_from_disk!/0

    #reset
    Application.put_env(:open_exchange_rates, :cache_file, cache_file)
  end

end
