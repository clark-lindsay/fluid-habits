defmodule FluidHabits.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      FluidHabits.Repo,
      # Start the Telemetry supervisor
      FluidHabitsWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: FluidHabits.PubSub},
      # Start the Endpoint (http/https)
      FluidHabitsWeb.Endpoint,
      # Start a worker by calling: FluidHabits.Worker.start_link(arg)
      # {FluidHabits.Worker, arg}
      {FluidHabits.AchievementRelay, name: FluidHabits.AchievementRelay}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: FluidHabits.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    FluidHabitsWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
