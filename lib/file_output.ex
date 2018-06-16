defmodule FileOutput do
  use GenStage
  require Logger

  def start_link(path) do
    GenStage.start_link(__MODULE__, %{path: path}, name: __MODULE__)
  end

  def init(%{path: path}) do
    Logger.info("Consumer #{__MODULE__} starting")
    GenStage.async_subscribe(__MODULE__, to: BookWriter, min_demand: 2, max_demand: 4)
    {:consumer, %{path: path}}
  end

  def handle_events(events, from, %{path: p} = state) do
    # Enum.each(events, &IO.write/1)

    {:ok, fd} = File.open(p, [:write, :append])
    Enum.each(events, &(IO.write(fd, &1)))
    File.close(fd)

    Logger.info("Consumer #{__MODULE__} received #{length(events)} events from #{inspect(from)}")
    {:noreply, [], state}
  end
end
