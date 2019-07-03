defmodule KV.Bucket do
  use Agent

  def start_link(_opts) do
    Agent.start_link(fn -> %{} end)
  end

  def get(bucket, key) do
    Agent.get(bucket, &Map.get(&1, key))
    #Agent.get(bucket, fn items -> Map.get(items, key) end)
  end

  def put(bucket, key, value) do
    Agent.update(bucket, &Map.put(&1, key, value))
    #Agent.update(bucket, fn items -> Map.put(items, key, value) end)
  end
end