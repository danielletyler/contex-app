defmodule ContexAppWeb.TutorialLive do
  use ContexAppWeb, :live_view

  def mount(_params, _, socket) do
    config = %{
      type: "bar",
      data: %{
        labels: ["A", "B", "C", "D", "E"],
        datasets: [%{data: [7, 7, 7, 7, 7]}]
      },
      options: %{
        scales: %{
          y: %{
            min: 0,
            max: 17
          }
        }
      }
    }

    {:ok, assign(socket, toggle: true) |> push_event("new-chart", %{config: config})}
  end

  def handle_event("change-data", _, %{assigns: %{toggle: toggle}} = socket) do
    dataset =
      case toggle do
        true -> [5, 4, 3, 2, 1]
        _ -> [3, 3, 3, 3, 3]
      end

    {:noreply, assign(socket, toggle: !toggle) |> push_event("update-points", %{points: dataset})}
  end

  def render(assigns) do
    ~H"""
    <canvas id="my-chart" phx-hook="BarChartJS"></canvas>
    <button phx-click="change-data">press</button>
    """
  end
end
