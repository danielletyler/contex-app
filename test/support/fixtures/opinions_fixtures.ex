defmodule ContexApp.OpinionsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `ContexApp.Opinions` context.
  """

  @doc """
  Generate a opinion.
  """
  def opinion_fixture(attrs \\ %{}) do
    {:ok, opinion} =
      attrs
      |> Enum.into(%{
        opinion: "some opinion",
        topic: "some topic"
      })
      |> ContexApp.Opinions.create_opinion()

    opinion
  end
end
