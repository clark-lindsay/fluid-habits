defmodule FluidHabits.Broadcasters.Broadcaster do
  @moduledoc false
  @callback broadcast(term(), binary(), term()) :: :ok | {:error, term()}

  def broadcast(module, topic, message), do: impl().broadcast(module, topic, message)

  defp impl do
    Application.get_env(
      :fluid_habits,
      :broadcaster,
      FluidHabits.Broadcasters.PhoenixPubSubBroadcaster
    )
  end
end
