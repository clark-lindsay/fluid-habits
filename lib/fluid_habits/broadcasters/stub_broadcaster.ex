defmodule FluidHabits.Broadcasters.StubBroadcaster do
  @behaviour FluidHabits.Broadcasters.Broadcaster

  @impl FluidHabits.Broadcasters.Broadcaster
  def broadcast(_, _, _) do
    :ok
  end
end
