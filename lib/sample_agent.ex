defmodule SampleAgent do
  use Agent
  require Logger

  def start_link(_) do
    Logger.info("#{__MODULE__} started")
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def stop() do
    Agent.stop(__MODULE__)
  end
end
