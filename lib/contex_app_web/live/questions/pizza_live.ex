defmodule ContexAppWeb.Questions.PizzaLive do
  alias ContexAppWeb.Helpers
  alias ContexApp.Opinions
  alias Phoenix.PubSub
  use ContexAppWeb, :live_view

  @topic "Pizza"

  def mount(_params, _, socket) do
    if connected?(socket), do: PubSub.subscribe(ContexApp.PubSub, @topic)
    {:ok, assign(socket, graph: get_graph(), echarts_graph: get_echarts_graph(), toggle: true)}
  end

  def handle_event("add-opinion", %{"opinion" => opinion}, socket) do
    Opinions.create_opinion(%{topic: @topic, opinion: opinion})
    PubSub.broadcast(ContexApp.PubSub, @topic, "new-opinion")
    {:noreply, socket}
  end

  def handle_event("toggle", _, %{assigns: %{toggle: t}} = socket) do
    {:noreply, assign(socket, toggle: !t)}
  end

  def handle_info("new-opinion", socket) do
    {:noreply, assign(socket, graph: get_graph(), echarts_graph: get_echarts_graph())}
  end

  def render(assigns) do
    ~H"""
    <div>
      <div class="flex gap-8 mb-4 pb-8 items-end border-b border-zinc-100">
        <h3>Does Pineapple Belong on Pizza?</h3>
        <div class="flex gap-4">
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
        </div>
      </div>
      <h5 phx-click="toggle" class="cursor-pointer hover:underline mb-12">Toggle chart</h5>
      <div>
        <div :if={@toggle}>
          <%= @graph %>
        </div>
        <%!-- ECharts --%>
        <div :if={!@toggle} id="bar" phx-hook="EChart" class="m-8">
          <div id="bar-chart" phx-update="ignore" style="width: 600px; height: 500px;" />
          <div id="bar-data" hidden><%= Jason.encode!(@echarts_graph) %></div>
        </div>
      </div>
    </div>
    """
  end

  defp get_data do
    @topic
    |> Opinions.get_opinions_by_topic()
    |> Enum.reduce({0, 0}, fn x, acc ->
      {yes, no} = acc

      case x.opinion do
        "Yes" -> {yes + 1, no}
        _ -> {yes, no + 1}
      end
    end)
  end

  defp get_graph do
    {yes, no} = get_data()

    Helpers.create_bar_graph(
      [
        {"Yes", yes},
        {"No", no}
      ],
      "Opinions vs Votes"
    )
  end

  defp get_echarts_graph do
    {yes, no} = get_data()

    %{
      title: %{
        text: "Opinions vs. Votes"
      },
      xAxis: %{
        type: "category",
        data: ["Yes", "No"]
      },
      yAxis: %{
        type: "value"
      },
      series: [
        %{
          data: [yes, no],
          type: "bar"
        }
      ],
      label: %{
        show: true,
        position: "inside"
      }
    }
  end
end
