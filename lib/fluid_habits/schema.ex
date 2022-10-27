defmodule FluidHabits.Schema do
  defmacro __using__(_) do
    quote do
      use TypedEctoSchema

      @timestamps_opts [type: :utc_datetime_usec]
    end
  end
end
