defmodule KV.Registry do
  use GenServer


  #Client API functions

  def start_link(opts) do
    #second argument is passed into init/1 callback
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def lookup(server, name) do
    #second argument (tuple) must match first argument of handle_call
    GenServer.call(server, {:lookup, name})
  end

  def create(server, name) do
    GenServer.cast(server, {:create, name})
  end

  #Server functions

  @impl true
  def init(:ok) do
    {:ok, %{}}
  end

  @impl true
  #calls are synchronous
  def handle_call({:lookup, name}, _from, names) do
    {:reply, Map.fetch(names, name), names}
  end

  @impl true
  #casts are asynchronous
  def handle_cast({:create, name}, names) do
    if Map.has_key?(names, name) do
      {:noreply, names}
    else
      {:ok, bucket} = KV.Bucket.start_link([])
      {:noreply, Map.put(names, name, bucket)}
    end
  end
end
