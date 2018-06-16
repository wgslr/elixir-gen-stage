defmodule GenStageSampleSup do
  use Supervisor

  ## API

  def start_link(args \\ []) do
    Supervisor.start_link(__MODULE__, args, [])
  end

  ## Callbacks

  def init(args \\ []) do
    inpath = Keyword.get(args, :inpath, "assets/medium.txt")
    outpath = Keyword.get(args, :outpath, "output.txt")

    children = [
      {BookWriter, [inpath]},
      %{
        id: ShellOutput,
        start: {ShellOutput, :start_link, [[]]},
        restart: :transient,
        shutdown: 100
      },
      %{
        id: FileOutput,
        start: {FileOutput, :start_link, [outpath]},
        restart: :transient,
        shutdown: 100
      }
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
