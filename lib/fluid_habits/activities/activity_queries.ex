defmodule FluidHabits.Activities.ActivityQueries do
  @moduledoc """
  Composable functions for building queries to retrieve
  information information related to `Activity`s from the DB
  """

  import Ecto.Query, only: [from: 2]

  alias FluidHabits.Accounts.User

  def for_user(queryable, %User{} = user) do
    from(act in queryable, where: act.user_id == ^user.id)
  end

  def for_user(queryable, user_id) when is_integer(user_id) do
    from(act in queryable, where: act.user_id == ^user_id)
  end
end
