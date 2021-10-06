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
  defp process(%{item: %{data: data, user_id: user_id}}) do
    Process.sleep(1000)
    HelloSocketsWeb.Endpoint.broadcast!("user:#{user_id}", "push", data)
  end
end
