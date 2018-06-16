defmodule GenStageSampleSup do
  use Supervisor

  ## API

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  ## Callbacks

  def init(_args) do
    children = [
      {BookWriter, ["assets/medium.txt"]},
      %{id: ShellOutput, start: {ShellOutput, :start_link, [[]]}, restart: :transient},
      %{id: FileOutput, start: {FileOutput, :start_link, ["output"]}, restart: :transient}
    ]

    Supervisor.init(children, strategy: :rest_for_one)
  end
end
