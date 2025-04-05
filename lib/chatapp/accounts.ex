defmodule Chatapp.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Chatapp.Repo
  alias Chatapp.Accounts.{User, UserToken}

  ## Database getters


  def get_user_by_username(username) when is_binary(username) do
    Repo.get_by(User, username: username)
  end


  @spec get_user_by_username_and_password(binary(), binary()) :: any()
  def get_user_by_username_and_password(username, password)
      when is_binary(username) and is_binary(password) do
    user = Repo.get_by(User, username: username)
    if User.valid_password?(user, password), do: user
  end


  def get_user!(id), do: Repo.get!(User, id)


  def register_user(attrs) do
    IO.puts("Attempting to register user with username: #{attrs["username"]}")

  # Create a timestamp for the current time
    now = DateTime.utc_now() |> DateTime.truncate(:second)

    changeset = %User{}
      |> User.registration_changeset(attrs)
      |> Ecto.Changeset.put_change(:confirmed_at, now)

    IO.puts("Registration changeset valid? #{changeset.valid?}")
    if not changeset.valid? do
      IO.inspect(changeset.errors, label: "Registration errors")
    end

    case Repo.insert(changeset) do
      {:ok, user} ->
        IO.puts("User successfully created with ID: #{user.id}")
        {:ok, user}
      {:error, changeset} ->
        IO.puts("Failed to create user:")
        IO.inspect(changeset.errors, label: "Insert errors")
        {:error, changeset}
    end
  end

  def change_user_registration(%User{} = user, attrs \\ %{}) do
    User.registration_changeset(user, attrs, hash_password: false, validate_username: false)
  end


  def change_user_password(user, attrs \\ %{}) do
    User.password_changeset(user, attrs, hash_password: false)
  end


  def update_user_password(user, password, attrs) do
    changeset =
      user
      |> User.password_changeset(attrs)
      |> User.validate_current_password(password)

    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, changeset)
    |> Ecto.Multi.delete_all(:tokens, UserToken.by_user_and_contexts_query(user, :all))
    |> Repo.transaction()
    |> case do
      {:ok, %{user: user}} -> {:ok, user}
      {:error, :user, changeset, _} -> {:error, changeset}
    end
  end

  ## Session

  def generate_user_session_token(user) do
    {token, user_token} = UserToken.build_session_token(user)
    Repo.insert!(user_token)
    token
  end


  def get_user_by_session_token(token) do
    {:ok, query} = UserToken.verify_session_token_query(token)
    Repo.one(query)
  end


  def delete_user_session_token(token) do
    Repo.delete_all(UserToken.by_token_and_context_query(token, "session"))
    :ok
  end

end
