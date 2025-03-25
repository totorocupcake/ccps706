defmodule Chatapp.Repo.Migrations.RenameEmailToUsername do
  use Ecto.Migration

  def change do
    rename table(:users), :email, to: :username
    drop_if_exists index(:users, [:email])
    create unique_index(:users, [:username])
  end
end
