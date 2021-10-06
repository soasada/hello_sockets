defmodule HelloSockets.Pipeline.Worker do
  # Starts new process for every item received in the data pipeline
  def start_link(item) do
    Task.start_link(
      fn ->
        process(item)
      end
    )
  end

  # Simulate some work
  defp process(item) do
    IO.inspect(item)
    Process.sleep(1000)
  end
end
