defmodule GenStageSampleSup do
  use Supervisor

  ## API

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)

  end

  ## Callbacks

  def init(_args) do
    children = [
      SampleAgent
    ]
    Supervisor.init(children, strategy: :one_for_one)
  end
end
