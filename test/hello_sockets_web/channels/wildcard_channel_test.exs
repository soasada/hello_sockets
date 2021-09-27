defmodule HelloSocketsWeb.WildcardChannelTest do
  use HelloSocketsWeb.ChannelCase
  alias HelloSocketsWeb.UserSocket

  describe "join/3 success" do
    test "ok when numbers in the format a:b where b = 2a" do
      assert {:ok, _, %Phoenix.Socket{}} =
               socket(UserSocket, nil, %{})
               |> subscribe_and_join("wild:2:4", %{})

      assert {:ok, _, %Phoenix.Socket{}} =
               socket(UserSocket, nil, %{})
               |> subscribe_and_join("wild:100:200", %{})
    end
  end

  describe "join/3 error" do
    test "error when b is not exactly twice a" do
      assert socket(UserSocket, nil, %{})
             |> subscribe_and_join("wild:1:3", %{}) == {:error, %{}}
    end

    test "error when 3 numbers are provided" do
      assert socket(UserSocket, nil, %{})
             |> subscribe_and_join("wild:1:2:3", %{}) == {:error, %{}}
    end
  end

  describe "join/3 error causing crash" do
    test "error with an invalid format topic" do
      assert socket(UserSocket, nil, %{})
             |> subscribe_and_join("wild:invalid", %{}) == {:error, %{}}
    end
  end

  describe "handle_in ping" do
    test "a pong response is provided" do
      assert {:ok, _, socket} =
               socket(UserSocket, nil, %{})
               |> subscribe_and_join("wild:2:4", %{})

      ref = push(socket, "ping", %{}) # this invoke handle_in on the Channel
      expected_reply = %{ping: "pong"}
      assert_reply ref, :ok, ^expected_reply
    end
  end
end
