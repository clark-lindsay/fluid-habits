defmodule FluidHabits.Broadcasters.MockBroadcaster do
  @behaviour FluidHabits.Broadcasters.Broadcaster

  @impl FluidHabits.Broadcasters.Broadcaster
  def broadcast(_module, topic, message) do
    IO.inspect(message, label: 'Broadcast for topic `#{topic}`')
  end
end
