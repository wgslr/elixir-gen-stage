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
    Logger.info("Consumer #{__MODULE__} received #{length(events)} events from #{inspect(from)}")
    GenStageSample.delay()

    process(events, state)

    Logger.info("Consumer #{__MODULE__} processed #{length(events)} events")
    {:noreply, [], state}
  end

  def terminate(reason, _state) do
    Logger.warn("Terminating with reason #{inspect(reason)}")
  end

  defp process(events, _state) do
    Enum.each(events, &IO.write(IO.ANSI.magenta() <> &1 <> IO.ANSI.default_color()))
  end
end
