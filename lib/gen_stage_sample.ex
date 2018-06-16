defmodule GenStageSample do
  # use Application

  # def start(_type, _args) do
  #   GenStageSampleSup.start_link([])
  # end

  def delay(time \\ Application.get_env(:gen_stage_sample, :delay, 0)) do
    :timer.sleep(time)
  end
end
