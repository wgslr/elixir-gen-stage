defmodule ShellOutput do
  use GenStage
  require Logger

  def start_link(_opts \\ []) do
    GenStage.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    Logger.info("Consumer starting")
    GenStage.async_subscribe(__MODULE__, to: BookWriter, min_demand: 2, max_demand: 4)
    {:consumer, nil}
  end

  def handle_events(events, from, state) do


    # Enum.each(events, &IO.write/1)
    Enum.each(events, &IO.write/1)

    Logger.info("Consumer #{__MODULE__} received #{length(events)} events from #{inspect(from)}")

    {:noreply, [], state}
  end
end
