defmodule ContexAppWeb.HomeLive do
  # In Phoenix v1.6+ apps, the line is typically: use MyAppWeb, :live_view
  use ContexAppWeb, :live_view

  def mount(_params, _, socket) do
    {:ok, assign(socket, :temperature, 80)}
  end

  def render(assigns) do
    ~H"""
    Current temperature: <%= @temperature %>
    """
  end
end
