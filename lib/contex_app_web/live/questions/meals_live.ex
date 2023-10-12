defmodule ContexAppWeb.Questions.MealsLive do
  alias ContexAppWeb.Helpers
  alias ContexApp.Opinions
  alias Phoenix.PubSub
  use ContexAppWeb, :live_view

  @topic "Meals"

  def mount(_params, _, socket) do
    if connected?(socket), do: PubSub.subscribe(ContexApp.PubSub, @topic)

    {:ok,
     assign(socket,
       breakfast: 1,
       lunch: 2,
       dinner: 3,
       graph: get_graph(),
       echarts_graph: get_echarts_graph(),
       toggle: true
     )}
  end

  def handle_event("toggle", _, %{assigns: %{toggle: t}} = socket) do
    {:noreply, assign(socket, toggle: !t)}
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
    {:noreply, assign(socket, graph: get_graph(), echarts_graph: get_echarts_graph())}
  end

  def render(assigns) do
    ~H"""
    <div>
      <h3>
        Most important meal of the day??
      </h3>
      <h5>Rank the three meals from most (1) to least (3) important</h5>
      <div>
        <.form for={%{}} phx-submit="submit" class="flex gap-4 py-8 mb-2 border-b border-zinc-100">
          <div>
            Breakfast
            <.input
              phx-change="update-vote"
              name="breakfast"
              type="select"
              value={@breakfast}
              options={[1, 2, 3]}
            />
          </div>
          <div>
            Lunch
            <.input
              phx-change="update-vote"
              name="lunch"
              type="select"
              value={@lunch}
              options={[1, 2, 3]}
            />
          </div>
          <div>
            Dinner
            <.input
              phx-change="update-vote"
              name="dinner"
              type="select"
              value={@dinner}
              options={[1, 2, 3]}
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
        <div id="stack-chart" phx-update="ignore" style="width: 600px; height: 500px;" />
        <div id="stack-data" hidden><%= Jason.encode!(@echarts_graph) %></div>
      </div>
    </div>
    """
  end

  defp get_data do
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
  end

  defp get_graph do
    {breakfast, lunch, dinner} = get_data()

    Helpers.create_stacked_bar_graph(
      [
        ["breakfast"] ++ breakfast,
        ["lunch"] ++ lunch,
        ["dinner"] ++ dinner
      ],
      "Meals"
    )
  end

  defp get_echarts_graph do
    {breakfast, lunch, dinner} = get_data()

    %{
      tooltip: %{
        trigger: "axis",
        axisPointer: %{
          type: "shadow"
        }
      },
      legend: %{},
      grid: %{
        left: "3%",
        right: "4%",
        bottom: "3%",
        containLabel: true
      },
      yAxis: %{
        type: "value"
      },
      xAxis: %{
        type: "category",
        data: ["Most", "Kinda", "Least"]
      },
      series: [
        %{
          name: "Breakfast",
          type: "bar",
          stack: "total",
          label: %{
            show: true
          },
          emphasis: %{
            focus: "series"
          },
          data: breakfast
        },
        %{
          name: "Lunch",
          type: "bar",
          stack: "total",
          label: %{
            show: true
          },
          emphasis: %{
            focus: "series"
          },
          data: lunch
        },
        %{
          name: "Dinner",
          type: "bar",
          stack: "total",
          label: %{
            show: true
          },
          emphasis: %{
            focus: "series"
          },
          data: dinner
        }
      ]
    }
  end
end
