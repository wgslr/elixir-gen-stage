defmodule FileOutput do
  use GenStage
  require Logger

  def start_link(path) do
    GenStage.start_link(__MODULE__, %{path: path}, name: __MODULE__)
  end

  def init(%{path: path}) do
    Logger.info("Consumer #{__MODULE__} starting")
    GenStageSample.delay()
    Logger.info("Consumer #{__MODULE__} subscribing to #{BookWriter}")
    GenStage.async_subscribe(__MODULE__, to: BookWriter, min_demand: 2, max_demand: 4)
    {:consumer, %{path: path}}
  end

  def handle_events(events, from, state) do
    Logger.info("Consumer #{__MODULE__} received #{length(events)} events from #{inspect(from)}")
    GenStageSample.delay()

    process(events, state)

    Logger.info("Consumer #{__MODULE__} processed #{length(events)} events")
    {:noreply, [], state}
  end

  def terminate(reason, _state) do
    Logger.warn("Terminating with reason #{inspect(reason)}")
  end

  defp process(events, %{path: path}) do
    {:ok, fd} = File.open(path, [:write, :append, :utf8])
    Enum.each(events, &IO.write(fd, &1))
    File.close(fd)
  end
end
