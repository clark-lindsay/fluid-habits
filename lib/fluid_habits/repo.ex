defmodule FluidHabits.Repo do
  use Ecto.Repo,
    otp_app: :fluid_habits,
    adapter: Ecto.Adapters.Postgres
end
