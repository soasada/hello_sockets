defmodule HelloSocketsWeb.WildcardChannel do
  use Phoenix.Channel

  # here we implement authorization
  def join("wild:" <> numbers, _payload, socket) do
    if valid_numbers?(numbers) do
      {:ok, socket}
    else
      {:error, %{}}
    end
  end

  def handle_in("ping", _payload, socket) do
    {:reply, {:ok, %{ping: "pong"}}, socket}
  end

  defp valid_numbers?(numbers) do
    try do
      numbers
      |> String.split(":")
      |> Enum.map(&String.to_integer/1)
      |> case do
           [a, b] when b == a * 2 -> true
           _ -> false
         end
    catch _type, _value -> false
    end
  end
end
