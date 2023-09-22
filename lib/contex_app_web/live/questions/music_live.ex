defmodule ContexAppWeb.Questions.MusicLive do
  alias ContexAppWeb.Helpers
  alias Phoenix.PubSub
  alias ContexApp.Opinions
  use ContexAppWeb, :live_view

  @topic "Music"

  def mount(_params, _session, socket) do
    if connected?(socket), do: PubSub.subscribe(ContexApp.PubSub, @topic)
    {:ok, assign(socket, graph: get_chatre_graph(), contex_graph: get_contex_graph(), toggle_graph: false)}
  end

  def handle_event("select", %{"genre" => genre}, socket) do
    Opinions.create_opinion(%{topic: @topic, opinion: genre})
    PubSub.broadcast(ContexApp.PubSub, @topic, "new-opinion")
    {:noreply, socket}
  end

  def handle_event("toggle", _, %{assigns: %{toggle_graph: t}} = socket) do
    {:noreply, assign(socket, toggle_graph: !t)}
  end

  def handle_info("new-opinion", socket) do
    {:noreply, assign(socket, graph: get_chatre_graph(), contex_graph: get_contex_graph())}
  end

  def render(assigns) do
    ~H"""
    <div>
    <div class="flex justify-between">
    <div>
      Choose your favorite music genre!
      <div>
        <button phx-click="select" phx-value-genre="Rock">Rock</button>
        <button phx-click="select" phx-value-genre="Country">Country</button>
        <button phx-click="select" phx-value-genre="Pop">Pop</button>
        <button phx-click="select" phx-value-genre="Jazz">Jazz</button>
        <button phx-click="select" phx-value-genre="Classical">Classical</button>
      </div>
      </div>
      <button phx-click="toggle">toggle</button>
      </div>
      <div :if={@toggle_graph} id="pie" phx-hook="Chart">
        <div id="pie-chart" phx-update="ignore" style="width: 700px; height: 700px;" />
        <div id="pie-data" hidden><%= Jason.encode!(@graph) %></div>
      </div>
      <div :if={!@toggle_graph} class="mt-12">
        <%= @contex_graph %>
      </div>
    </div>
    """
  end

  defp get_chatre_graph do
    {rock, country, pop, jazz, classical} =
      @topic
      |> Opinions.get_opinions_by_topic()
      |> Enum.reduce({0, 0, 0, 0, 0}, fn %{opinion: genre}, acc ->
        {r, co, p, j, cl} = acc

        case genre do
          "Rock" -> {r + 1, co, p, j, cl}
          "Country" -> {r, co + 1, p, j, cl}
          "Pop" -> {r, co, p + 1, j, cl}
          "Jazz" -> {r, co, p, j + 1, cl}
          "Classical" -> {r, co, p, j, cl + 1}
        end
      end)

    %{
      title: %{text: "Genres", left: "center", top: "center"},
      animation: "auto",
      series: [
        %{
          type: "pie",
          data: [
            %{name: "Rock", value: rock},
            %{name: "Country", value: country},
            %{name: "Pop", value: pop},
            %{name: "Jazz", value: jazz},
            %{name: "Classical", value: classical}
          ],
          radius: ["40%", "70%"]
        }
      ]
    }
  end

  defp get_contex_graph do
    {rock, country, pop, jazz, classical} =
      @topic
      |> Opinions.get_opinions_by_topic()
      |> Enum.reduce({0, 0, 0, 0, 0}, fn %{opinion: genre}, acc ->
        {r, co, p, j, cl} = acc

        case genre do
          "Rock" -> {r + 1, co, p, j, cl}
          "Country" -> {r, co + 1, p, j, cl}
          "Pop" -> {r, co, p + 1, j, cl}
          "Jazz" -> {r, co, p, j + 1, cl}
          "Classical" -> {r, co, p, j, cl + 1}
        end
      end)

    data = [
      ["Rock", rock],
      ["Country", country],
      ["Pop", pop],
      ["Jazz", jazz],
      ["Classical", classical]
    ]

    Helpers.create_pie_chart(data)
  end
end
