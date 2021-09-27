defmodule HelloSocketsWeb.RecurringChannel do
  use Phoenix.Channel

  @send_after_millis 5_000

  # here we implement authorization
  def join(_topic, _payload, socket) do
    schedule_send_token()
    {:ok, socket}
  end

  def handle_info(:send_token, socket) do
    schedule_send_token()
    push(socket, "new_token", %{token: new_token(socket)})
    {:noreply, socket}
  end

  defp schedule_send_token do
    Process.send_after(self(), :send_token, @send_after_millis)
  end

  defp new_token(socket = %{assigns: %{user_id: user_id}}) do
    Phoenix.Token.sign(socket, "salt identifier", user_id)
  end
end
