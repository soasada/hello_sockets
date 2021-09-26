defmodule HelloSocketsWeb.AuthChannel do
  use Phoenix.Channel
  require Logger

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
end
