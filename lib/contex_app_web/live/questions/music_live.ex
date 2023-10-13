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
       toggle: true,
       genre: nil
     )}
  end

  def handle_event("select", %{"genre" => genre}, socket) do
    {:noreply, assign(socket, genre: genre)}
  end

  def handle_event("submit", %{"genre" => genre}, socket) do
    Opinions.create_opinion(%{topic: @topic, opinion: genre})
    PubSub.broadcast(ContexApp.PubSub, @topic, "new-opinion")
    {:noreply, socket}
  end

  def handle_event("toggle", _, %{assigns: %{toggle: t}} = socket) do
    {:noreply, assign(socket, toggle: !t)}
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
      <div class="flex border-b border-zinc-100 gap-8 pb-8 mb-2">
        <div>
          <h3>
            Choose your favorite music genre!
          </h3>
          <h5>(Out of this very niche and exclusive selection)</h5>
        </div>
        <.form for={%{}} phx-submit="submit" class="flex gap-4">
          <.input
            label=""
            name="genre"
            type="select"
            placeholder="Select a genre"
            value={@genre}
            phx-change="select"
            options={["Rock", "Country", "Pop", "Hip-hop", "Jazz"]}
          />
          <.button class="h-max my-2">Submit</.button>
        </.form>
      </div>
      <h5 phx-click="toggle" class="cursor-pointer hover:underline">Toggle chart</h5>
      <div class="mt-12">
        <%!-- ContEx --%>
        <div :if={@toggle}>
          <%= @contex_graph %>
        </div>
        <%!-- ECharts --%>
        <div :if={!@toggle} id="pie" phx-hook="EChart">
          <div id="pie-chart" phx-update="ignore" style="width: 500px; height: 400px;" />
          <div id="pie-data" hidden><%= Jason.encode!(@echarts_graph) %></div>
        </div>
      </div>
    </div>
    """
  end

  defp get_data do
    @topic
    |> Opinions.get_opinions_by_topic()
    |> Enum.reduce([0, 0, 0, 0, 0], fn %{opinion: genre}, acc ->
      [r, co, p, j, hh] = acc

      case genre do
        "Rock" -> [r + 1, co, p, j, hh]
        "Country" -> [r, co + 1, p, j, hh]
        "Pop" -> [r, co, p + 1, j, hh]
        "Jazz" -> [r, co, p, j + 1, hh]
        "Hip-hop" -> [r, co, p, j, hh + 1]
      end
    end)
  end

  defp get_echarts_graph do
    [rock, country, pop, jazz, hh] = get_data()

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
            %{name: "Hip-hop", value: hh}
          ],
          radius: ["40%", "70%"]
        }
      ]
    }
  end

  defp get_contex_graph do
    [rock, country, pop, jazz, hh] = get_data()

    data = [
      {"Rock", rock},
      {"Country", country},
      {"Pop", pop},
      {"Jazz", jazz},
      {"Hip-hop", hh}
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
