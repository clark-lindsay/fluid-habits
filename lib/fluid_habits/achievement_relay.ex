defmodule FluidHabits.AchievementRelay do
  alias FluidHabits.Broadcasters.Broadcaster
  alias FluidHabits.Activities

  use GenServer

  def start_link(_any) do
    GenServer.start_link(__MODULE__, %{})
  end

  # not sure if I am going to want to maintain any state yet
  @impl GenServer
  def init(_init_arg) do
    :ok = Phoenix.PubSub.subscribe(FluidHabits.PubSub, "achievement")

    {:ok, %{}}
  end

  @impl GenServer
  def handle_info({:create, %{achievement: %{activity: activity}}}, state) do
    active_streak_start = Activities.active_streak_start(activity)

    Broadcaster.broadcast(
      PubSub,
      "achievement_metadata",
      {:streak_update, %{active_streak_start: active_streak_start}}
    )

    {:noreply, state}
  end
end
