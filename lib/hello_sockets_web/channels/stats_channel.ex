defmodule HelloSocketsWeb.StatsChannel do
  use Phoenix.Channel
  require Logger
  alias HelloSockets.Statix

  # here we implement authorization
  def join("valid", _payload, socket) do
    channel_join_increment("success")
    {:ok, socket}
  end

  def join("invalid", _payload, _socket) do
    channel_join_increment("fail")
    {:error, %{reason: "always fail"}}
  end

  defp channel_join_increment(status) do
    Statix.increment("channel_join", 1, tags: ["status:#{status}", "channel:StatsChannel"])
  end
end
