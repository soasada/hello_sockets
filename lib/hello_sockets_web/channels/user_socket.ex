defmodule HelloSocketsWeb.UserSocket do
  use Phoenix.Socket

  channel "ping", HelloSocketsWeb.PingChannel
  channel "dupe", HelloSocketsWeb.DedupeChannel

  # here we implement authentication
  @impl true
  def connect(_params, socket, _connect_info) do
    {:ok, socket}
  end

  @impl true
  def id(_socket), do: nil
end
