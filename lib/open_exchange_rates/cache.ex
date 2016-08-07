defmodule OpenExchangeRates.Cache do
  use GenServer

  def start_link, do: GenServer.start_link(__MODULE__, :waiting_for_data, name: __MODULE__)

  def update!(rates) do
    GenServer.call(__MODULE__, {:update!, rates})
  end

  # callbacks

  def handle_call({:update!, rates}, _caller, _state), do: {:reply, :ok, rates}

  def handle_call({:currencies}, _caller, state), do: {:reply, Map.keys(state), state}

  def handle_call({:get_rate, currency}, _caller, state) do
    result = case Map.get(state, currency) do
      nil -> {:error, "Currency unknown"}
      rate -> {:ok, rate}
    end

    {:reply, result, state}
  end


  def handle_call({:convert_cents, cents, :USD, to}, _caller, state) do
    rate = Map.get(state, Atom.to_string(to))
    converted = Kernel.round(cents * rate)
    {:reply, {:ok, converted}, state}
  end

  def handle_call({:convert_cents, cents, from, :USD}, _caller, state) do
    rate_to_usd = Map.get(state, Atom.to_string(from))
    converted = Kernel.round(cents / rate_to_usd)
    {:reply, {:ok, converted}, state}
  end

  def handle_call({:convert_cents, cents, from, to}, _caller, state) do
    rate_to_usd = Map.get(state, Atom.to_string(from))
    rate = Map.get(state, Atom.to_string(to))
    usd = cents / rate_to_usd
    converted = Kernel.round(usd * rate)
    {:reply, {:ok, converted}, state}
  end

end
