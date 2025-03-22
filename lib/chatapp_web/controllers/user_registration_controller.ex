defmodule ChatappWeb.UserRegistrationController do
  use ChatappWeb, :controller

  alias Chatapp.Accounts

  def create(conn, %{"user" => user_params}) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        {:ok, _} =
          Accounts.deliver_user_confirmation_instructions(
            user,
            &url(~p"/users/confirm/#{&1}")
          )

        conn
        |> put_flash(:info, "User created successfully.")
        |> redirect(to: ~p"/users/log_in")

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_flash(:error, "Registration failed. Please check your input.")
        |> redirect(to: ~p"/users/register")
    end
  end
end
