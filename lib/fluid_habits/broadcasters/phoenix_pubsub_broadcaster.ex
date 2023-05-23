defmodule FluidHabits.Broadcasters.PhoenixPubSubBroadcaster do
  @moduledoc false
  @behaviour FluidHabits.Broadcasters.Broadcaster

  @impl FluidHabits.Broadcasters.Broadcaster
  def broadcast(module, topic, message) do
    Phoenix.PubSub.broadcast(module, topic, message)
  end
end
