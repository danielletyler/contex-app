defmodule ContexAppWeb.HomeLive do
  # In Phoenix v1.6+ apps, the line is typically: use MyAppWeb, :live_view
  use ContexAppWeb, :live_view

  def mount(_params, _, socket) do
    {:ok, assign(socket, :temperature, 80)}
  end

  def render(assigns) do
    ~H"""
    <div class="flex flex-col gap-4">
      <a href="/tutorial" class="text-5xl">🗒️</a>
      <a href="/pizza" class="text-5xl">🍕</a>
      <a href="/meeting-stress" class="text-5xl">🤓</a>
      <a href="/meals" class="text-5xl">🍣</a>
      <a href="/music" class="text-5xl">🎼</a>
    </div>
    """
  end
end
