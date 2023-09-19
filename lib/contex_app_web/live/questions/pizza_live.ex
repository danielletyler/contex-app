defmodule ContexAppWeb.Questions.PizzaLive do
  alias ContexAppWeb.Helpers
  alias ContexApp.Opinions
  alias Phoenix.PubSub
  use ContexAppWeb, :live_view

  @topic "Pizza"

  def mount(_params, _, socket) do
    if connected?(socket), do: PubSub.subscribe(ContexApp.PubSub, @topic)
    {:ok, assign(socket, graph: get_graph())}
  end

  def handle_event("add-opinion", %{"opinion" => opinion}, socket) do
    Opinions.create_opinion(%{topic: @topic, opinion: opinion})
    PubSub.broadcast(ContexApp.PubSub, @topic, "new-opinion")
    {:noreply, socket}
  end

  def handle_info("new-opinion", socket) do
    {:noreply, assign(socket, graph: get_graph())}
  end

  def render(assigns) do
    ~H"""
    <div>
      <h3>Does Pineapple Belong on Pizza?</h3>
      <div>
        <button
          class="bg-green-500 hover:bg-green-700"
          phx-click="add-opinion"
          phx-value-opinion="Yes"
        >
          YES
        </button>
        <button class="bg-red-500 hover:bg-red-700" phx-click="add-opinion" phx-value-opinion="No">
          NO
        </button>
        <%= @graph %>
      </div>
    </div>
    """
  end

  defp get_graph do
    {yes, no} =
      @topic
      |> Opinions.get_opinions_by_topic()
      |> Enum.reduce({0, 0}, fn x, acc ->
        {yes, no} = acc

        case x.opinion do
          "Yes" -> {yes + 1, no}
          _ -> {yes, no + 1}
        end
      end)

    Helpers.create_bar_graph(
      [
        {"Yes", yes},
        {"No", no}
      ],
      "Opinions vs Votes"
    )
  end
end
