defmodule ContexApp.Repo.Migrations.CreateOpinions do
  use Ecto.Migration

  def change do
    create table(:opinions) do
      add :topic, :string
      add :opinion, :string

      timestamps()
    end
  end
end
