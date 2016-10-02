defmodule ExBots.Brain do
  def start_link do
    Agent.start_link(fn -> Map.new end, name: __MODULE__)
  end

  def memorize(key, info) do
    Agent.update(__MODULE__, &Map.put(&1, key, info))
  end

  def remember(key) do
    Agent.get(__MODULE__, &Map.get(&1, key))
  end

  def remember_lazy(key, fun) when is_function(fun, 0) do
    case remember(key) do
      nil ->
        value = fun.()
        memorize(key, value)
        value
      value -> value
    end
  end

  def forget(key) do
    Agent.update(__MODULE__, &Map.delete(&1, key))
  end
end
