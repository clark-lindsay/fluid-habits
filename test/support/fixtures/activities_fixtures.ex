defmodule FluidHabits.ActivitiesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `FluidHabits.Activities` context.
  """

  @doc """
  Generate a activity.
  """
  def activity_fixture(attrs \\ %{}) do
    {:ok, activity} =
      attrs
      |> Enum.into(%{
        description: "some description",
        name: "some name"
      })
      |> FluidHabits.Activities.create_activity()

    activity
  end
end
