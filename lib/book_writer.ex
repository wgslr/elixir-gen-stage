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

  def init(%{path: path} = opts) do
    {:ok, fd} = File.open(path, [:read])
    {:producer, %{fd: fd}}
  end

  def handle_demand(demand, %{fd: fd} = state) do
    Logger.info("Received demand for #{demand} lines")

    events = Enum.reduce_while(1..demand, [], fn _, lines ->
      case IO.gets(fd) do
        :eof -> {:halt, lines}
        line when is_binary(line) -> {:cont, [line | lines]}
      end
    end) |> Enum.reverse()

    if length(events) < demand do
      Logger.warning("Could read only #{length(events)} lines when demand is #{demand}")
    end

    # events = case Stream.take(s, deman) do
    #   lines when length(lines) == demand -> lines
    #   lines ->
    #     Logger.warning("Not enough lines in the source to satisfy demand"))
    # end

    # TODO store demand

    Logger.info("#{self()} sending #{length(events)} events")

    {:noreply, events, state}
  end



end
