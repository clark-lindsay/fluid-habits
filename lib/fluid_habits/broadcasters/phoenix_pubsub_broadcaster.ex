defmodule FluidHabits.Broadcasters.PhoenixPubSubBroadcaster do
  @behaviour FluidHabits.Broadcasters.Broadcaster

  @impl FluidHabits.Broadcasters.Broadcaster
  def broadcast(module, topic, message) do
    Phoenix.PubSub.broadcast(module, topic, message)
  end
end
