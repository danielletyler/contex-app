defmodule ContexAppWeb.Questions.MealsLive do
  alias ContexAppWeb.Helpers
  alias ContexApp.Opinions
  alias Phoenix.PubSub
  use ContexAppWeb, :live_view

  @topic "Meals"

  def mount(_params, _, socket) do
    if connected?(socket), do: PubSub.subscribe(ContexApp.PubSub, @topic)
    {:ok, assign(socket, breakfast: 1, lunch: 2, dinner: 3, graph: get_graph())}
  end

  def handle_event("update-vote", %{"breakfast" => breakfast}, socket) do
    {:noreply, assign(socket, breakfast: breakfast)}
  end

  def handle_event("update-vote", %{"lunch" => lunch}, socket) do
    {:noreply, assign(socket, lunch: lunch)}
  end

  def handle_event("update-vote", %{"dinner" => dinner}, socket) do
    {:noreply, assign(socket, dinner: dinner)}
  end

  def handle_event(
        "submit",
        %{"breakfast" => breakfast, "lunch" => lunch, "dinner" => dinner},
        socket
      ) do
    Opinions.create_opinion(%{topic: @topic, opinion: "#{breakfast}:#{lunch}:#{dinner}"})
    PubSub.broadcast(ContexApp.PubSub, @topic, "new-opinion")
    {:noreply, socket}
  end

  def handle_info("new-opinion", socket) do
    {:noreply, assign(socket, graph: get_graph())}
  end

  def render(assigns) do
    ~H"""
    <div>
      <h1 class="mb-12">
        Most important meal of the day?? Rank the three meals from most (1) to least (3) important
      </h1>
      <div>
        <.form for={%{}} phx-submit="submit" class="flex gap-4">
          <div>
            breakfast
            <.input
              phx-change="update-vote"
              name="breakfast"
              type="select"
              value={@breakfast}
              options={[1, 2, 3]}
            />
          </div>
          <div>
            lunch
            <.input
              phx-change="update-vote"
              name="lunch"
              type="select"
              value={@lunch}
              options={[1, 2, 3]}
            />
          </div>
          <div>
            dinner
            <.input
              phx-change="update-vote"
              name="dinner"
              type="select"
              value={@dinner}
              options={[1, 2, 3]}
            />
          </div>
          <.button>Submit</.button>
        </.form>
      </div>
      <%= @graph %>
    </div>
    """
  end

  defp get_graph do
    {breakfast, lunch, dinner} =
      @topic
      |> Opinions.get_opinions_by_topic()
      |> Enum.reduce(
        {
          [0, 0, 0],
          [0, 0, 0],
          [0, 0, 0]
        },
        fn x, acc ->
          {b, l, d} = acc

          [breakfast, lunch, dinner] = String.split(x.opinion, ":")

          b = List.update_at(b, String.to_integer(breakfast) - 1, &(&1 + 1))
          l = List.update_at(l, String.to_integer(lunch) - 1, &(&1 + 1))
          d = List.update_at(d, String.to_integer(dinner) - 1, &(&1 + 1))

          {b, l, d}
        end
      )
      |> IO.inspect()

    Helpers.create_stacked_bar_graph(
      [
        ["breakfast"] ++ breakfast,
        ["lunch"] ++ lunch,
        ["dinner"] ++ dinner
      ],
      "Meals"
    )
  end
end
