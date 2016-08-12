defmodule OpenExchangeRates.Client do
  @moduledoc """
  This module takes care of the API communication between openexchangerates.org and is for internal use only
  """
  require Logger

  @app_id Application.get_env(:open_exchange_rates, :app_id)

  @doc false
  @spec get_latest() :: {:ok, Map.t} | {:error, String.t}
  def get_latest do
    response = HTTPoison.get("https://openexchangerates.org/api/latest.json?base=USD&app_id=#{@app_id}")
    case response do
      {:ok, %HTTPoison.Response{body: json, status_code: 200}} -> json |> handle_api_success
      {:ok, %HTTPoison.Response{body: json}} -> json |> handle_api_error
      {:error, _} = error -> error
    end
  end

  defp handle_api_success(json) do
    data = Poison.decode!(json)
    {:ok, data}
  end

  defp handle_api_error(body) do
    case Poison.decode(body) do
      {:ok, data} ->
        if data["message"] == "invalid_app_id", do: Logger.error("OpenExchangeRates: The app id `#{@app_id}` is not valid !")
        {:error, data["description"]}
      _ -> {:error, "Could not parse the JSON : #{inspect body}"}
    end
  end
end
