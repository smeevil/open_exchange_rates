defmodule OpenExchangeRates.Cache do
  @app_id Application.get_env(:open_exchange_rates, :app_id)

  use GenServer
  require Logger

  def start_link do
    {:ok, pid} = GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(_opts) do
    data = load_from_disk |> Poison.decode!

    spawn_link(fn ->
      :timer.apply_interval(:timer.seconds(60), __MODULE__, :check_update, [])
      :timer.sleep(:infinity) #make sure the process does not exit
    end)

    OpenExchangeRates.Cache.check_update
    {:ok, %{rates: data["rates"], fetched_at: 0, data_timestamp: data["timestamp"]}}
  end

  def get_rate(currency) do
    GenServer.call(__MODULE__, {:get_rate, currency})
  end

  def update do
    GenServer.cast(__MODULE__, {:update, []})
  end

  def check_update do
    GenServer.cast(__MODULE__, {:check_update, []})
  end

  def timestamp do
    GenServer.call(__MODULE__, {:timestamp, []})
  end

  def write_to_disk(data) do
    File.cwd! <> "/priv/latest.json" |> File.write!(data)
  end

  def load_from_disk do
    File.cwd! <> "/priv/latest.json" |> File.read!
  end

  # callbacks

  def handle_call({:timestamp, _options}, _caller, state) do
    result = case state[:data_timestamp] do
      nil -> {:error, "Cache is not initialized"}
      timestamp -> {:ok, timestamp}
    end

    {:reply, result, state}
  end

  def handle_call({:currencies}, _caller, state) do
    {:reply, Map.keys(state[:rates]), state}
  end

  def handle_call({:get_rate, currency}, _caller, state) do
    result = case state[:rates][currency] do
      nil -> {:error, "Currency unknown"}
      rate -> {:ok, rate}
    end

    {:reply, result, state}
  end

  def handle_call({:convert_cents, cents, :USD, to}, _caller, state) do
    rate = state[:rates][Atom.to_string(to)]
    converted = (cents * rate) |> Kernel.round
    {:reply, {:ok, converted}, state}
  end

  def handle_call({:convert_cents, cents, from, :USD}, _caller, state) do
    rate_to_usd = state[:rates][Atom.to_string(from)]
    converted = (cents / rate_to_usd) |> Kernel.round
    {:reply, {:ok, converted}, state}
  end

  def handle_call({:convert_cents, cents, from, to}, _caller, state) do
    rate_to_usd = state[:rates][Atom.to_string(from)]
    usd = (cents / rate_to_usd)
    rate = state[:rates][Atom.to_string(to)]
    usd = cents / rate_to_usd
    converted = (usd * rate) |> Kernel.round
    {:reply, {:ok, converted}, state}
  end

  def handle_call({:update, _options}, _caller, state) do
    case OpenExchangeRates.Client.get_latest do
      {:ok, data} ->
        Logger.debug "OpenExchangeRates Updated Rates"
        state = data_to_state(data)
        {:reply, {:ok, state, state}}
      {:error, message} -> {:reply, {:error ,message}, state}
    end
  end

  def handle_cast({:check_update, _}, state) do
    Logger.debug "OpenExchangeRates should check for update"
    diff =  (:os.system_time(:seconds) - state[:fetched_at]) / 60
    cache_time = Application.get_env(:open_exchange_rates, :cache_time_in_minutes, 3600)
    Logger.debug "OpenExchangeRates diff #{inspect diff} and cache_time: #{inspect cache_time}"

    if (diff >= cache_time) do
      case OpenExchangeRates.Client.get_latest do
        {:ok, data} -> 
          Logger.debug "OpenExchangeRates Updated Rates"
          {:noreply, data_to_state(data)}
        {:error, message} ->
          Logger.debug "OpenExchangeRates Could not updates states duo to : #{inspect message}."
          {:noreply, state}
      end
    else
      {:noreply, state}
    end
  end
  defp data_to_state(data) do
    %{rates: data["rates"], data_timestamp: data["timestamp"], fetched_at: :os.system_time(:seconds)}
  end

end
