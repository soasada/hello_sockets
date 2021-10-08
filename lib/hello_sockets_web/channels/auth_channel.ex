defmodule HelloSocketsWeb.AuthChannel do
  use Phoenix.Channel
  require Logger
  alias HelloSockets.Pipeline.Timing

  intercept ["push_timed"]

  # here we implement authorization
  def join("user:" <> req_user_id, _payload, socket) do
    if req_user_id == to_string(socket.assigns.user_id) do
      {:ok, socket}
    else
      Logger.error("#{__MODULE__} failed #{req_user_id} != #{socket.assigns.user_id}")
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_in("ping", _payload, socket) do
    {:reply, {:ok, %{ping: "pong"}}, socket}
  end

  def handle_out("push_timed", %{data: data, at: enqueued_at}, socket) do
    push(socket, "push_timed", data)
    HelloSockets.Statix.histogram("pipeline.push_delivered", Timing.unix_ms_now() - enqueued_at)
    {:noreply, socket}
  end
end
