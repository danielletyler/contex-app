defmodule ContexApp.Opinions.Opinion do
  use Ecto.Schema
  import Ecto.Changeset

  schema "opinions" do
    field :opinion, :string
    field :topic, :string

    timestamps()
  end

  @doc false
  def changeset(opinion, attrs) do
    opinion
    |> cast(attrs, [:topic, :opinion])
    |> validate_required([:topic, :opinion])
  end
end
