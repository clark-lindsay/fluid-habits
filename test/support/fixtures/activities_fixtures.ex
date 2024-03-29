defmodule FluidHabits.ActivitiesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `FluidHabits.Activities` context.
  """

  alias FluidHabits.AccountsFixtures

  @doc """
  Generate a activity.
  """
  def activity_fixture(attrs \\ %{}) do
    user = attrs[:user] || AccountsFixtures.user_fixture()

    activity_attrs = Enum.into(attrs, %{description: "some description", name: "some name"})

    {:ok, activity} = FluidHabits.Activities.create_activity(user, activity_attrs)

    activity
  end
end
