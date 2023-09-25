defmodule ContexAppWeb.Questions.MusicLive do
  alias ContexAppWeb.Helpers
  alias Phoenix.PubSub
  alias ContexApp.Opinions
  use ContexAppWeb, :live_view

  @topic "Music"

  def mount(_params, _session, socket) do
    if connected?(socket), do: PubSub.subscribe(ContexApp.PubSub, @topic)

    {:ok,
     assign(socket,
       echarts_graph: get_echarts_graph(),
       contex_graph: get_contex_graph(),
       type: "contex"
     )}
  end

  def handle_event("select", %{"genre" => genre}, socket) do
    Opinions.create_opinion(%{topic: @topic, opinion: genre})
    PubSub.broadcast(ContexApp.PubSub, @topic, "new-opinion")
    {:noreply, socket}
  end

  def handle_event("change-chart", %{"type" => type}, socket) do
    {:noreply, assign(socket, type: type)}
  end

  def handle_info("new-opinion", socket) do
    socket =
      socket
      |> assign(echarts_graph: get_echarts_graph())
      |> assign(contex_graph: get_contex_graph())

    {:noreply, socket}
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
        <div class="flex flex-col gap-2">
          <button phx-click="change-chart" phx-value-type="contex">ContEx</button>
          <button phx-click="change-chart" phx-value-type="echarts">ECharts</button>
        </div>
      </div>
      <%!-- ContEx --%>
      <div :if={@type == "contex"}>
        <%= @contex_graph %>
      </div>
      <%!-- ECharts --%>
      <div :if={@type == "echarts"} id="pie" phx-hook="EChart">
        <div id="pie-chart" phx-update="ignore" style="width: 500px; height: 400px;" />
        <div id="pie-data" hidden><%= Jason.encode!(@echarts_graph) %></div>
      </div>
    </div>
    """
  end

  defp get_data do
    @topic
    |> Opinions.get_opinions_by_topic()
    |> Enum.reduce([0, 0, 0, 0, 0], fn %{opinion: genre}, acc ->
      [r, co, p, j, cl] = acc

      case genre do
        "Rock" -> [r + 1, co, p, j, cl]
        "Country" -> [r, co + 1, p, j, cl]
        "Pop" -> [r, co, p + 1, j, cl]
        "Jazz" -> [r, co, p, j + 1, cl]
        "Classical" -> [r, co, p, j, cl + 1]
      end
    end)
  end

  defp get_echarts_graph do
    [rock, country, pop, jazz, classical] = get_data()

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
    [rock, country, pop, jazz, classical] = get_data()

    data = [
      {"Rock", rock},
      {"Country", country},
      {"Pop", pop},
      {"Jazz", jazz},
      {"Classical", classical}
    ]

    opts = [
      mapping: %{category_col: "Genre", value_col: "Count"},
      # colour_palette: ["D0CFEC", "07BEB8", "F15156", "274C77", "EDBF85"],
      legend_setting: :legend_right,
      data_labels: true,
      title: "Favorite Music Genre"
    ]

    Helpers.create_pie_chart(data, ["Genre", "Count"], opts)
  end
end
