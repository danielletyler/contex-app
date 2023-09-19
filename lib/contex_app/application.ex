defmodule ContexApp.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      ContexAppWeb.Telemetry,
      # Start the Ecto repository
      ContexApp.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: ContexApp.PubSub},
      # Start Finch
      {Finch, name: ContexApp.Finch},
      # Start the Endpoint (http/https)
      ContexAppWeb.Endpoint
      # Start a worker by calling: ContexApp.Worker.start_link(arg)
      # {ContexApp.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ContexApp.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ContexAppWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
