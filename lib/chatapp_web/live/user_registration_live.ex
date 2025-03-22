defmodule ChatappWeb.UserRegistrationLive do
  use ChatappWeb, :live_view

  alias Chatapp.Accounts
  alias Chatapp.Accounts.User

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <.header class="text-center">
        Register for an account
        <:subtitle>
          Already registered?
          <.link navigate={~p"/users/log_in"} class="font-semibold text-brand hover:underline">
            Log in
          </.link>
          to your account now.
        </:subtitle>
      </.header>

      <.simple_form
      for={@form}
      id="registration_form"
      action={~p"/users/register"}
      method="post"
      phx-update="ignore"
    >
        <.error :if={@check_errors}>
          Oops, something went wrong! Please check the errors below.
        </.error>

        <.input field={@form[:email]} type="email" label="Email" required />

        <.input field={@form[:password]} type="password" label="Password" required />
        <div class="text-sm text-gray-600 mb-3">
          Password must be at least 12 characters long
        </div>

        <:actions>
          <.button phx-disable-with="Creating account..." class="w-full">Create an account</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    IO.puts("UserRegistrationLive mounted")
    changeset = Accounts.change_user_registration(%User{})

    socket =
      socket
      |> assign(trigger_submit: false, check_errors: false)
      |> assign_form(changeset)

    {:ok, socket, temporary_assigns: [form: nil]}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    IO.puts("Registration attempt with email: #{user_params["email"]}")
    IO.puts("Password length: #{String.length(user_params["password"] || "")}")

    case Accounts.register_user(user_params) do
      {:ok, user} ->
        IO.puts("Registration successful!")
        {:ok, _} =
          Accounts.deliver_user_confirmation_instructions(
            user,
            &url(~p"/users/confirm/#{&1}")
          )

        # Redirect to login page instead of using trigger_submit
        {:noreply,
         socket
         |> put_flash(:info, "User created successfully. Please log in.")
         |> redirect(to: ~p"/users/log_in")}

      {:error, %Ecto.Changeset{} = changeset} ->
        IO.puts("Registration failed with errors:")
        IO.inspect(changeset.errors, label: "Validation errors")
        {:noreply, socket |> assign(check_errors: true) |> assign_form(changeset)}
    end
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = Accounts.change_user_registration(%User{}, user_params)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "user")

    if changeset.valid? do
      assign(socket, form: form, check_errors: false)
    else
      assign(socket, form: form)
    end
  end
end
