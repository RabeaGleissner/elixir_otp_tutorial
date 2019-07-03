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
    names = %{}
    refs = %{}
    {:ok, {names, refs}}
  end

  @impl true
  #calls are synchronous, should be default choice
  def handle_call({:lookup, name}, _from, state) do
    {names, _} = state
    {:reply, Map.fetch(names, name), state}
  end

  @impl true
  #casts are asynchronous, use sparingly, here only used as an example
  def handle_cast({:create, name}, {names, refs}) do
    if Map.has_key?(names, name) do
      {:noreply, {names, refs}}
    else
      {:ok, bucket} = KV.Bucket.start_link([])
      ref = Process.monitor(bucket)
      refs = Map.put(refs, ref, name)
      names = Map.put(names, name, bucket)
      {:noreply, {names, refs}}
    end
  end

  #used for any other messages that are not sent from call/2 or cast/2
  def handle_info({:DOWN, ref, :process, _pid, _reason}, {names, refs}) do
    {name, refs} = Map.pop(refs, ref)
    names = Map.delete(names, name)
    {:noreply, {names, refs}}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end
end
