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
    {:ok, fd} = File.open(path, [:read])
    {:producer, %{fd: fd}, dispatcher: GenStage.BroadcastDispatcher}
  end

  def handle_demand(demand, %{fd: fd} = state) do
    Logger.info("Received demand for #{demand} lines")

    events = Enum.reduce_while(1..demand, [], fn _, lines ->
      case IO.read(fd, :line) do
        :eof -> {:halt, lines}
        line when is_binary(line) -> {:cont, [line | lines]}
      end
    end) |> Enum.reverse()

    if length(events) < demand do
      Logger.warn("Could read only #{length(events)} lines when demand is #{demand}")
      send(self(), {:stop, :eof})
    end

    Logger.info("#{__MODULE__} sending #{length(events)} events")

    {:noreply, events, state}
  end

  def handle_info({:stop, reason}, state) do
    {:stop, reason, state}
  end



end
