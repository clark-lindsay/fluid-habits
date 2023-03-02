defmodule FluidHabits.AchievementRelay do
  alias FluidHabits.Broadcasters.Broadcaster
  alias FluidHabits.Activities

  use GenServer

  def start_link(_any) do
    GenServer.start_link(__MODULE__, %{})
  end

  @impl GenServer
  def init(_init_arg) do
    # subscribe to updates for all users
    # TODO: spin out a genserver per user, to avoid SGP issues
    :ok = Phoenix.PubSub.subscribe(FluidHabits.PubSub, "user:*")

    {:ok, %{}}
  end

  @impl GenServer
  def handle_info({:create_achievement, %{achievement: %{activity: activity}}}, state) do
    active_streak = Activities.active_streak(activity)

    Broadcaster.broadcast(
      FluidHabits.PubSub,
      "user:#{activity.user_id}",
      {:streak_update, %{active_streak: active_streak}}
    )

    {:noreply, state}
  end
end
