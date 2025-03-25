defmodule ChatappWeb.DefaultChannel do
  use ChatappWeb, :channel

  @impl true
  def join("default:lobby", payload, socket) do
    if authorized?(payload) do
      send(self(), :after_join)
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  @impl true
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (default:lobby).
  @impl true
  def handle_in("shout", payload, socket) do
    broadcast(socket, "shout", payload)
    {:noreply, socket}
  end

  def handle_in("new_message", payload, socket) do
    user = Chatapp.Accounts.get_user!(socket.assigns.user_id)
    enhanced_payload = Map.put(payload, "name", user.username)

    spawn(fn -> save_message(enhanced_payload) end)
    broadcast(socket, "new_message", enhanced_payload)

    {:noreply, socket}
  end

  defp save_message(message) do
    Chatapp.Message.changeset(%Chatapp.Message{}, message) |> Chatapp.Repo.insert
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end

  @impl true
  def handle_info(:after_join, socket) do
    Chatapp.Message.recent_messages()
    |> Enum.each(fn msg -> push(socket, "new_message", format_msg(msg)) end)

    username = case socket.assigns.user_id do
      user_id when is_integer(user_id) ->
        user = Chatapp.Accounts.get_user!(user_id)
        user.username
      _ ->
        "Someone"
    end

    push(socket, "new_message", %{name: "System", message: "#{username} joined the chat"})

    {:noreply, socket}
  end

  defp format_msg(msg) do
    %{
      name: msg.name,
      message: msg.message
    }
  end

end
