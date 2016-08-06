defmodule OpenExchangeRates.Client do
  @app_id Application.get_env(:open_exchange_rates, :app_id)

  #TODO : How do we cache base currencies ?
  def get_latest(base \\ "USD") do
    response = HTTPoison.get("https://openexchangerates.org/api/latest.json?base=#{base}&app_id=#{@app_id}")
    case response do
      {:ok, %HTTPoison.Response{body: json, status_code: 200}} -> json |> handle_api_success
      {:ok, %HTTPoison.Response{body: json}}-> json |> handle_api_error
      {:error, _} = error -> error
    end
  end

  defp handle_api_success(json) do
    OpenExchangeRates.Cache.write_to_disk(json)
    data = Poison.decode!(json)
    {:ok, data}
  end

  defp handle_api_error(body) do
    data = Poison.decode!(body)
    {:error, data["description"]}
  end
end
