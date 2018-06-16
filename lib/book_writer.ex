defmodule BookWriter do
  @moduledoc """
  GenStage produer which simulates writing a book
  by reading consecutive lines from a file and sending
  them to consumers.
  """

  use GenStage
  require Logger

  def start_link(path) do
    GenStage.start_link(__MODULE__, %{path: path}, name: __MODULE__)
  end

  def init(%{path: path}) do
    Logger.info("BookWriter starting for file #{path}")
    GenStageSample.delay()

    {:ok, fd} = File.open(path, [:read, :utf8])
    {:producer, %{fd: fd}, dispatcher: GenStage.BroadcastDispatcher}
  end

  def handle_demand(demand, %{fd: fd} = state) do
    Logger.warn("Received demand for #{demand} lines")

    GenStageSample.delay()

    events =
      Enum.reduce_while(1..demand, [], fn _, lines ->
        case IO.read(fd, :line) do
          :eof -> {:halt, lines}
          line when is_binary(line) -> {:cont, [line | lines]}
        end
      end)
      |> Enum.reverse()

    if length(events) < demand do
      Logger.warn("Could read only #{length(events)} lines when demand is #{demand}")
      send(self(), {:stop, :eof})
    end

    Logger.info("#{__MODULE__} sending #{length(events)} events")
    GenStageSample.delay()
    {:noreply, events, state}
  end

  def handle_info({:stop, :eof}, state) do
    {:stop, :normal, state}
  end
end
