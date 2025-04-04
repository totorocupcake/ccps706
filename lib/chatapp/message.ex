defmodule Chatapp.Message do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  schema "messages" do
    field :message, :string
    field :name, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:name, :message])
    |> validate_required([:name, :message])
  end

  def recent_messages(limit \\ 30) do
    from(m in Chatapp.Message,  # Use full module name or alias it
      order_by: [desc: m.inserted_at],
      limit: ^limit
    )
    |> Chatapp.Repo.all()
  end


end
