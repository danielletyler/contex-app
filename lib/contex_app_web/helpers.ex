defmodule ContexAppWeb.Helpers do
  def create_bar_graph(data, title, subtitle \\ "", x_label \\ "", y_label \\ "") do
    data
    |> Contex.Dataset.new()
    |> Contex.Plot.new(Contex.BarChart, 500, 400)
    |> Contex.Plot.titles(title, subtitle)
    |> Contex.Plot.axis_labels(x_label, y_label)
    |> Contex.Plot.to_svg()
  end

  def create_point_plot(data, ranges, x_label, y_label, title, subtitle \\ "") do
    x_scale =
      Contex.ContinuousLinearScale.new()
      |> Contex.ContinuousLinearScale.domain(ranges.x_min, ranges.x_max)

    y_scale =
      Contex.ContinuousLinearScale.new()
      |> Contex.ContinuousLinearScale.domain(ranges.y_min, ranges.y_max)

    data
    |> Contex.Dataset.new()
    |> Contex.Plot.new(Contex.PointPlot, 500, 400,
      custom_x_scale: x_scale,
      custom_y_scale: y_scale
    )
    |> Contex.Plot.titles(title, subtitle)
    |> Contex.Plot.axis_labels(x_label, y_label)
    |> Contex.Plot.to_svg()
  end
end
