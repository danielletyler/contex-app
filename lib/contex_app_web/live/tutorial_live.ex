defmodule ContexAppWeb.TutorialLive do
  use ContexAppWeb, :live_view

  def mount(_params, _, socket) do
    games = [
      {"Tic-Tac-Toe", 3.4285714285714284},
      {"Ping Pong", 2.5714285714285716},
      {"Pictionary", 2.625}
    ]

    chart =
      games
      |> Contex.Dataset.new()
      |> Contex.BarChart.new()

    plot =
      Contex.Plot.new(400, 500, chart)
      |> Contex.Plot.titles("Game Ratings", "average stars per game")
      |> Contex.Plot.axis_labels("games", "stars")
      |> Contex.Plot.to_svg()

    {:ok, assign(socket, plot: plot, chart: chart)}
  end

  def handle_event("update", _, %{assigns: %{chart: chart}} = socket) do
    {_name, old} = Enum.at(chart.dataset.data, 0)

    games = [
      {"Tic-Tac-Toe", old + 1},
      {"Ping Pong", 2.5714285714285716},
      {"Pictionary", 2.625}
    ]

    new_chart =
      games
      |> Contex.Dataset.new()
      |> Contex.BarChart.new()

    plot =
      Contex.Plot.new(400, 500, new_chart)
      |> Contex.Plot.titles("Game Ratings", "average stars per game")
      |> Contex.Plot.axis_labels("games", "stars")
      |> Contex.Plot.to_svg()

    {:noreply, assign(socket, plot: plot, chart: new_chart)}
  end

  def render(assigns) do
    ~H"""
    <%= @plot %>
    <div>
      <button
        phx-click="update"
        class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded"
      >
        test
      </button>
    </div>
    """
  end
end
