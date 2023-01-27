Ecto.Adapters.SQL.Sandbox.mode(FluidHabits.Repo, :manual)

{:ok, _} = Application.ensure_all_started(:mox)

Mox.defmock(FluidHabits.Broadcasters.MockBroadcaster,
  for: FluidHabits.Broadcasters.Broadcaster
)

ExUnit.start()
