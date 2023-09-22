defmodule ContexAppWeb.Helpers do
  def create_bar_graph(data, title, subtitle \\ "", x_label \\ "", y_label \\ "") do
    data
    |> Contex.Dataset.new()
    |> Contex.Plot.new(Contex.BarChart, 500, 400)
    |> Contex.Plot.titles(title, subtitle)
    |> Contex.Plot.axis_labels(x_label, y_label)
    |> Contex.Plot.to_svg()
  end

  def create_stacked_bar_graph(data, title, subtitle \\ "", x_label \\ "", y_label \\ "") do
    series_cols = ["Most", "Kinda", "Least"]

    options = [
      mapping: %{category_col: "Category", value_cols: ["Most", "Kinda", "Least"]},
      type: :stacked,
      data_labels: true,
      orientation: :vertical,
      colour_palette: ["96bfff", "f196ff", "ff9838"],
      series_columns: series_cols
    ]

    data
    |> Contex.Dataset.new(["Category" | series_cols])
    |> Contex.Plot.new(Contex.BarChart, 500, 400, options)
    |> Contex.Plot.titles(title, subtitle)
    |> Contex.Plot.axis_labels(x_label, y_label)
    |> Contex.Plot.plot_options(%{legend_setting: :legend_right})
    |> Contex.Plot.to_svg()
  end

  def create_point_plot(data, ranges, x_label, y_label, title, subtitle \\ "")

  def create_point_plot([], ranges, x_label, y_label, title, subtitle) do
    x_scale =
      Contex.ContinuousLinearScale.new()
      |> Contex.ContinuousLinearScale.domain(ranges.x_min, ranges.x_max)

    y_scale =
      Contex.ContinuousLinearScale.new()
      |> Contex.ContinuousLinearScale.domain(ranges.y_min, ranges.y_max)

    [{nil, nil}]
    |> Contex.Dataset.new()
    |> Contex.Plot.new(Contex.PointPlot, 500, 400,
      custom_x_scale: x_scale,
      custom_y_scale: y_scale
    )
    |> Contex.Plot.titles(title, subtitle)
    |> Contex.Plot.axis_labels(x_label, y_label)
    |> Contex.Plot.to_svg()
  end

  def create_point_plot(data, ranges, x_label, y_label, title, subtitle) do
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

  def create_pie_chart(data) do
    dataset = Contex.Dataset.new(data, ["Genre", "Count"])

    opts = [
      mapping: %{category_col: "Genre", value_col: "Count"},
      colour_palette: ["16a34a", "c13584", "499be4", "FF0000", "00f2ea"],
      legend_setting: :legend_right,
      data_labels: true,
      title: "Pie"
    ]

    Contex.Plot.new(dataset, Contex.PieChart, 600, 400, opts)
    |> Contex.Plot.to_svg()
  end
end
