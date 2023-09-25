defmodule ContexAppWeb.Questions.EngMeetingLive do
  alias ContexApp.Opinions
  alias ContexAppWeb.Helpers
  alias Phoenix.PubSub
  use ContexAppWeb, :live_view

  @topic "Stress"

  def mount(_params, _, socket) do
    if connected?(socket), do: PubSub.subscribe(ContexApp.PubSub, @topic)
    {:ok, assign(socket, stress: 0, time: 0, graph: get_graph(), echarts_graph: get_echarts_graph(), toggle: true)}
  end

  def handle_event("toggle", _, %{assigns: %{toggle: t}} = socket) do
    {:noreply, assign(socket, toggle: !t)}
  end

  def handle_event("update-stress", %{"stress" => stress}, socket) do
    {:noreply, assign(socket, stress: stress)}
  end

  def handle_event("update-time", %{"time" => time}, socket) do
    {:noreply, assign(socket, time: time)}
  end

  def handle_event("submit", %{"stress" => stress, "time" => time}, socket) do
    Opinions.create_opinion(%{topic: @topic, opinion: "#{time}:#{stress}"})
    PubSub.broadcast(ContexApp.PubSub, @topic, "new-opinion")
    {:noreply, socket}
  end

  def handle_info("new-opinion", socket) do
    {:noreply, assign(socket, graph: get_graph(), echarts_graph: get_echarts_graph())}
  end

  def render(assigns) do
    ~H"""
    <div>
      <.form for={%{}} phx-submit="submit">
        <div class="flex w-full items-end gap-8 mb-8">
          <.input
            label="How stressed are you about your engineering meeting?"
            name="stress"
            type="range"
            value={@stress}
            phx-change="update-stress"
            min="0"
            max="10"
            step="1"
            class="grow"
          />
          <div class="text-center py-2 w-8 border border-2 border-blue-600 rounded-md text-blue-700 font-bold">
            <%= @stress %>
          </div>
        </div>
        <.input
          label="When is your meeting scheduled for?"
          name="time"
          type="select"
          placeholder="Select a month"
          value={@time}
          phx-change="update-time"
          options={list_weeks()}
        />
        <.button class="mt-4 bg-blue-600">Submit</.button>
      </.form>
      <button phx-click="toggle">Toggle chart</button>
      <div :if={@toggle}>
        <%= @graph %>
      </div>
      <%!-- ECharts --%>
      <div id="point" phx-hook="EChart" :if={!@toggle}>
        <div id="point-chart" phx-update="ignore" style="width: 500px; height: 400px;" />
        <div id="point-data" hidden><%= Jason.encode!(@echarts_graph) %></div>
      </div>
    </div>
    """
  end

  defp get_data do
    @topic
    |> Opinions.get_opinions_by_topic()
    |> Enum.map(fn x ->
      [time, stress] =
        x.opinion
        |> String.split(":")

      [String.to_integer(time), String.to_integer(stress)]
    end)
  end

  defp get_graph do
    Helpers.create_point_plot(
      get_data(),
      %{x_min: 0, x_max: Enum.count(list_weeks()), y_min: 0, y_max: 10},
      "Weeks Until Meeting",
      "Stress Level",
      "Stress vs Time"
    )
  end

  def get_echarts_graph do
    %{
      xAxis: %{
        min: 0,
        max: 44,
        name: "Weeks until meeting",
        nameLocation: "middle",
        nameGap: 50
      },
      yAxis: %{
        min: 0,
        max: 10,
        name: "Stress Level",
        nameGap: 30,
        nameLocation: "center",
        nameRotate: 90
      },
      series: [
        %{
          symbolSize: 20,
          data: get_data(),
          type: "scatter"
        }
      ]
    }
  end

  defp list_weeks do
    Date.range(~D[2023-10-18], ~D[2024-08-21], 7)
    |> Enum.to_list()
    |> Enum.map(fn x ->
      Date.to_iso8601(x)
    end)
    |> Enum.with_index(fn x, index -> {x, index} end)
  end
end
