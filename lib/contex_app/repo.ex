defmodule ContexApp.Repo do
  use Ecto.Repo,
    otp_app: :contex_app,
    adapter: Ecto.Adapters.Postgres
end
