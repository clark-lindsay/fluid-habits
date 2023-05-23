defmodule FluidHabits.Broadcasters.MockBroadcaster do
  @moduledoc false
  @behaviour FluidHabits.Broadcasters.Broadcaster

  @impl FluidHabits.Broadcasters.Broadcaster
  def broadcast(_module, topic, message) do
    # credo:disable-for-next-line
    IO.inspect(message, label: 'Broadcast for topic `#{topic}`')

    :ok
  end
end
