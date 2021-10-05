defmodule HelloSocketsWeb.StatsChannel do
  use Phoenix.Channel
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

  def handle_in("ping", _payload, socket) do
    Statix.measure(
      "stats_channel.ping",
      fn ->
        Process.sleep(:rand.uniform(1000))
        {:reply, {:ok, %{ping: "pong"}}, socket}
      end
    )
  end

  def handle_in("slow_ping", _payload, socket) do
    Process.sleep(3_000)
    {:reply, {:ok, %{ping: "pong"}}, socket}
  end

  # Don't block the channel, instead dispatch the work to a GenServer or Task.
  #
  # Benefit of this pattern: increase parallelism if we have a slow database query or external API call.
  # Trade-off: lose the ability to slow down a client (back-pressure).
  #
  # A possible solution to the trade-off is to implement a mechanism to support a maximum amount of concurrency per channel.
  #
  # GenServer => long running process
  # Task => one time action process
  def handle_in("parallel_slow_ping", _payload, socket) do
    ref = socket_ref(socket)

    Task.start_link(
      fn ->
        Process.sleep(3_000)
        Phoenix.Channel.reply(ref, {:ok, %{ping: "pong"}})
      end
    )

    {:noreply, socket}
  end

  defp channel_join_increment(status) do
    Statix.increment("channel_join", 1, tags: ["status:#{status}", "channel:StatsChannel"])
  end
end
