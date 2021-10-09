defmodule HelloSocketsWeb.PipelineTest do
  use HelloSocketsWeb.ChannelCase, async: false
  alias HelloSocketsWeb.AuthSocket
  alias HelloSockets.Pipeline.Producer

  @user_id 1

  test "event are pushed from beginning to end correctly" do
    connect_auth_socket(@user_id)

    Enum.each(
      1..10,
      fn n ->
        Producer.push_timed(n, @user_id)
        assert_push "push_timed", %{n: ^n}
      end
    )
  end

  test "an event is not delivered to the wrong user" do
    connect_auth_socket(2)

    Producer.push_timed(%{test: true}, @user_id)
    refute_push "push_timed", %{test: true}
  end

  test "events are timed on delivery" do
    assert {:ok, _} = StatsDLogger.start_link(port: 8127, formatter: :send)
    connect_auth_socket(@user_id)

    Producer.push_timed(5, @user_id)

    assert_push "push_timed", %{n: 5}
    assert_receive {:statsd_recv, "pipeline.push_delivered", _value}
  end

  defp connect_auth_socket(user_id) do
    {:ok, _, %Phoenix.Socket{}} =
      socket(AuthSocket, nil, %{user_id: user_id})
      |> subscribe_and_join("user:#{user_id}", %{})
  end
end
