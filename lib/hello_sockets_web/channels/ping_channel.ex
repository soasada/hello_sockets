defmodule HelloSocketsWeb.PingChannel do
  use Phoenix.Channel

  intercept ["request_ping"]

  def join(_topic, _payload, socket) do
    {:ok, socket}
  end

  # There are three possible responses:
  #
  # Reply to a message:
  #   {:reply, {:ok, map()}, Phoenix.Socket}
  #
  # Do not reply to a message:
  #   {:noreply, Phoenix.Socket}
  #
  # Disconnect the Channel:
  #   {:stop, reason, Phoenix.Socket}
  def handle_in("ping", %{"ack_phrase" => ack_phrase}, socket) do
    {:reply, {:ok, %{ping: ack_phrase}}, socket}
  end

  def handle_in("ding", _payload, socket) do
    {:stop, :shutdown, {:ok, %{msg: "shutting down"}}, socket}
  end

  def handle_out("request_ping", payload, socket) do
    push(socket, "send_ping", Map.put(payload, "from_node", Node.self()))
    {:noreply, socket}
  end
end
