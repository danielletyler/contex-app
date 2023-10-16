defmodule ContexAppWeb.Questions.PowersLive do
  alias ContexAppWeb.Helpers
  alias ContexApp.Opinions
  alias Phoenix.PubSub
  use ContexAppWeb, :live_view

  @topic "Powers"

  def mount(_params, _, socket) do
    if connected?(socket), do: PubSub.subscribe(ContexApp.PubSub, @topic)

    {:ok,
     assign(socket,
       power: "Flight",
       graph: get_graph(),
       echarts_graph: get_echarts_graph(),
       toggle: true
     )}
  end

  def handle_event("toggle", _, %{assigns: %{toggle: t}} = socket) do
    {:noreply, assign(socket, toggle: !t)}
  end

  def handle_event("update-vote", %{"power" => power}, socket) do
    {:noreply, assign(socket, power: power)}
  end

  def handle_event(
        "submit",
        %{"power" => power},
        socket
      ) do
    Opinions.create_opinion(%{topic: @topic, opinion: power})
    PubSub.broadcast(ContexApp.PubSub, @topic, "new-opinion")
    {:noreply, socket}
  end

  def handle_info("new-opinion", socket) do
    {:noreply, assign(socket, graph: get_graph(), echarts_graph: get_echarts_graph())}
  end

  def render(assigns) do
    ~H"""
    <div>
      <div class="flex gap-4 items-center mb-2 border-b border-zinc-100">
        <h3>
          Which superpower would you most like to have?
        </h3>

        <.form for={%{}} phx-submit="submit" class="flex gap-4 py-8">
          <div>
            <.input
              phx-change="update-vote"
              name="power"
              type="select"
              value={@power}
              options={options()}
            />
          </div>
          <.button class="h-max m-2 self-end">Submit</.button>
        </.form>
      </div>
      <h5 phx-click="toggle" class="cursor-pointer hover:underline">Toggle chart</h5>
      <div :if={@toggle}>
        <%= @graph %>
      </div>
      <%!-- ECharts --%>
      <div :if={!@toggle} id="stack" phx-hook="EChart">
        <div id="stack-chart" phx-update="ignore" style="width: 800px; height: 500px;" />
        <div id="stack-data" hidden><%= Jason.encode!(@echarts_graph) %></div>
      </div>
    </div>
    """
  end

  defp options do
    [
      "Flight",
      "Strength",
      "Telekinesis",
      "Invisibility",
      "Teleportation",
      "Speed"
    ]
  end

  defp get_data do
    @topic
    |> Opinions.get_opinions_by_topic()
    |> Enum.reduce({0, 0, 0, 0, 0, 0}, fn x, acc ->
      {f, st, tk, i, tp, sp} = acc

      case x.opinion do
        "Flight" -> {f + 1, st, tk, i, tp, sp}
        "Strength" -> {f, st + 1, tk, i, tp, sp}
        "Telekinesis" -> {f, st, tk + 1, i, tp, sp}
        "Invisibility" -> {f, st, tk, i + 1, tp, sp}
        "Teleportation" -> {f, st, tk, i, tp + 1, sp}
        "Speed" -> {f, st, tk, i, tp, sp + 1}
      end
    end)
  end

  defp get_graph do
    {f, st, tk, i, tp, sp} = get_data()

    Helpers.create_bar_graph(
      [
        {"Flight", f},
        {"Strength", st},
        {"Telekinesis", tk},
        {"Invisibility", i},
        {"Teleportation", tp},
        {"Speed", sp}
      ],
      "SuperPower vs Votes"
    )
  end

  defp get_echarts_graph do
    data = Tuple.to_list(get_data())

    %{
      title: %{
        text: "SuperPower vs. Votes"
      },
      xAxis: %{
        type: "category",
        data: options()
      },
      yAxis: %{
        type: "value"
      },
      series: [
        %{
          data: data,
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
