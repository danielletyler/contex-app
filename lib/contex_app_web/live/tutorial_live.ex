defmodule ContexAppWeb.TutorialLive do
  use ContexAppWeb, :live_view

  def mount(_params, _, socket) do
    {:ok, assign(socket, graph: "bar")}
  end

  def handle_event("change_graph", %{"type" => type}, socket) do
    {:noreply, assign(socket, graph: type)}
  end

  def render(assigns) do
    ~H"""
    <div>
      <button phx-click="change_graph" phx-value-type="bar">bar</button>
      <button phx-click="change_graph" phx-value-type="point">point</button>
      <button phx-click="change_graph" phx-value-type="pie">pie</button>
    </div>
    <div :if={@graph == "bar"}>
      <%= bar_graph() %>
    </div>
    <div :if={@graph == "point"}>
      <%= point_plot() %>
    </div>
    <div :if={@graph == "pie"}>
      <%= pie_chart() %>
    </div>
    """
  end

  def bar_graph() do
    [{"A", 20}, {"B", 40}]
    |> Contex.Dataset.new()
    |> Contex.Plot.new(Contex.BarChart, 500, 400)
    |> Contex.Plot.titles("Title", "Subtitle")
    |> Contex.Plot.axis_labels("x_label", "y_label")
    |> Contex.Plot.to_svg()
  end

  def point_plot() do
    scale =
      Contex.ContinuousLinearScale.new()
      |> Contex.ContinuousLinearScale.domain(0, 10)

    [{1, 1}, {2, 2}, {3, 3}, {4, 4}, {5, 5}]
    |> Contex.Dataset.new()
    |> Contex.Plot.new(Contex.PointPlot, 500, 400, custom_x_scale: scale, custom_y_scale: scale)
    |> Contex.Plot.titles("Title", "Subtitle")
    |> Contex.Plot.axis_labels("x_label", "y_label")
    |> Contex.Plot.to_svg()
  end

  def pie_chart() do
    opts = [
      mapping: %{category_col: "Value", value_col: "Count"},
      legend_setting: :legend_right
    ]

    [{"A", 5}, {"B", 7}, {"C", 10}]
    |> Contex.Dataset.new(["Value", "Count"])
    |> Contex.Plot.new(Contex.PieChart, 600, 400, opts)
    |> Contex.Plot.titles("Title", "Subtitle")
    |> Contex.Plot.to_svg()
  end
end
