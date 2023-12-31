defmodule ContexApp.OpinionsTest do
  use ContexApp.DataCase

  alias ContexApp.Opinions

  describe "opinions" do
    alias ContexApp.Opinions.Opinion

    import ContexApp.OpinionsFixtures

    @invalid_attrs %{opinion: nil, topic: nil}

    test "list_opinions/0 returns all opinions" do
      opinion = opinion_fixture()
      assert Opinions.list_opinions() == [opinion]
    end

    test "get_opinion!/1 returns the opinion with given id" do
      opinion = opinion_fixture()
      assert Opinions.get_opinion!(opinion.id) == opinion
    end

    test "create_opinion/1 with valid data creates a opinion" do
      valid_attrs = %{opinion: "some opinion", topic: "some topic"}

      assert {:ok, %Opinion{} = opinion} = Opinions.create_opinion(valid_attrs)
      assert opinion.opinion == "some opinion"
      assert opinion.topic == "some topic"
    end

    test "create_opinion/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Opinions.create_opinion(@invalid_attrs)
    end

    test "update_opinion/2 with valid data updates the opinion" do
      opinion = opinion_fixture()
      update_attrs = %{opinion: "some updated opinion", topic: "some updated topic"}

      assert {:ok, %Opinion{} = opinion} = Opinions.update_opinion(opinion, update_attrs)
      assert opinion.opinion == "some updated opinion"
      assert opinion.topic == "some updated topic"
    end

    test "update_opinion/2 with invalid data returns error changeset" do
      opinion = opinion_fixture()
      assert {:error, %Ecto.Changeset{}} = Opinions.update_opinion(opinion, @invalid_attrs)
      assert opinion == Opinions.get_opinion!(opinion.id)
    end

    test "delete_opinion/1 deletes the opinion" do
      opinion = opinion_fixture()
      assert {:ok, %Opinion{}} = Opinions.delete_opinion(opinion)
      assert_raise Ecto.NoResultsError, fn -> Opinions.get_opinion!(opinion.id) end
    end

    test "change_opinion/1 returns a opinion changeset" do
      opinion = opinion_fixture()
      assert %Ecto.Changeset{} = Opinions.change_opinion(opinion)
    end
  end
end
