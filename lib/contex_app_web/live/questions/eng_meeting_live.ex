defmodule ContexAppWeb.Questions.EngMeetingLive do
  alias ContexApp.Opinions
  alias ContexAppWeb.Helpers
  alias Phoenix.PubSub
  use ContexAppWeb, :live_view

  @topic "Stress"

  def mount(_params, _, socket) do
    if connected?(socket), do: PubSub.subscribe(ContexApp.PubSub, @topic)
    {:ok, assign(socket, stress: 0, time: 0, graph: get_graph())}
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
    {:noreply, assign(socket, graph: get_graph())}
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
          options={list_months()}
        />
        <.button class="mt-4 bg-blue-600">Submit</.button>
      </.form>
      <%= @graph %>
    </div>
    """
  end

  defp get_graph do
    @topic
    |> Opinions.get_opinions_by_topic()
    |> Enum.map(fn x ->
      [time, stress] =
        x.opinion
        |> String.split(":")

      {String.to_integer(time), String.to_integer(stress)}
    end)
    |> Helpers.create_point_plot(
      %{x_min: 0, x_max: 12, y_min: 0, y_max: 10},
      "Months Until Meeting",
      "Stress Level",
      "Stress vs Time"
    )
  end

  defp list_months do
    [
      {"September 2023", 0},
      {"October 2023", 1},
      {"November 2023", 2},
      {"December 2023", 3},
      {"January 2024", 4},
      {"February 2024", 5},
      {"March 2024", 6},
      {"April 2024", 7},
      {"May 2024", 8},
      {"June 2024", 9},
      {"July 2024", 10},
      {"August 2024", 11}
    ]
  end
end
