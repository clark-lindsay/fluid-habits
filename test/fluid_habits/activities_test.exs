defmodule FluidHabits.ActivitiesTest do
  use FluidHabits.DataCase, async: true

  describe "activities" do
    alias FluidHabits.Activities.Activity
    alias FluidHabits.{Activities, AccountsFixtures}

    import FluidHabits.{ActivitiesFixtures, AchievementsFixtures}

    @invalid_attrs %{description: nil, name: nil}

    setup do
      valid_user = AccountsFixtures.user_fixture()

      %{valid_user: valid_user}
    end

    setup context, do: Mox.set_mox_from_context(context)

    test "list_activities/0 returns all activities" do
      activity = activity_fixture()
      assert Activities.list_activities() == [activity]
    end

    test "list_achievements_since/2 returns only achievements for the given activity" do
      activity = activity_fixture()
      %{id: associated_achievement_id} = achievement_fixture(%{activity: activity})
      _unrelated_achievement = achievement_fixture()

      assert [%{id: ^associated_achievement_id}] =
               Activities.list_achievements_since(activity, ~U[2000-01-01 00:00:00Z])
    end

    test "list_achievements_since/2 returns only `limit` # of achievements" do
      activity = activity_fixture()

      for _iteration <- 1..2 do
        achievement_fixture(%{activity: activity})
      end

      assert Activities.list_achievements_since(
               activity,
               ~U[2000-01-01 00:00:00Z],
               limit: 1
             )
             |> Enum.count() ==
               1
    end

    test "get_activity!/1 returns the activity with given id" do
      activity = activity_fixture()
      assert Activities.get_activity!(activity.id) == activity
    end

    test "create_activity/1 with valid data creates a activity", %{valid_user: valid_user} do
      valid_attrs = %{description: "some description", name: "some name"}

      assert {:ok, %Activity{} = activity} = Activities.create_activity(valid_user, valid_attrs)
      assert activity.description == "some description"
      assert activity.name == "some name"
    end

    test "active_streak/1 returns nil when there are no achievements _today_ or _yesterday_" do
      activity = activity_fixture()

      two_days_ago =
        DateTime.utc_now()
        |> Timex.shift(days: -2)
        |> Timex.end_of_day()

      achievement_fixture(activity: activity, inserted_at: two_days_ago)

      assert is_nil(Activities.active_streak(activity))

      yesterday =
        DateTime.utc_now()
        |> Timex.shift(days: -1)
        |> Timex.beginning_of_day()

      achievement_fixture(activity: activity, inserted_at: yesterday)

      refute is_nil(Activities.active_streak(activity))
    end

    test "active_streak/1 returns the date of the streak start with no end when there are _only_ achievements _today_" do
      activity = activity_fixture()

      achievement = achievement_fixture(activity: activity, inserted_at: DateTime.utc_now())

      {:single, start_date} = Activities.active_streak(activity)
      assert start_date == achievement.inserted_at
    end

    test "active_streak/1 returns the date of the oldest streak entry when the user's timezone causes gaps in UTC" do
      user = AccountsFixtures.user_fixture(timezone: "US/Eastern")

      activity = activity_fixture(user: user)

      two_days_ago_achievement =
        achievement_fixture(
          activity: activity,
          inserted_at:
            Timex.now(user.timezone)
            |> Timex.shift(days: -2)
            |> Timex.set(hour: 23)
            |> DateTime.shift_zone!("Etc/UTC")
        )

      assert Activities.active_streak(activity) == nil

      yesterday_achievement =
        achievement_fixture(
          activity: activity,
          inserted_at:
            Timex.now(user.timezone)
            |> Timex.shift(days: -1)
            |> Timex.set(hour: 23)
            |> DateTime.shift_zone!("Etc/UTC")
        )

      {:range, %{start: start_date, end: end_date}} = Activities.active_streak(activity)
      assert start_date == two_days_ago_achievement.inserted_at
      assert end_date == yesterday_achievement.inserted_at
    end

    test "active_streak/1 returns the date of the oldest streak entry when there are gaps" do
      activity = activity_fixture()

      achievement_insertion_times =
        for days_ago <- [0, 1, 2, 3, 5] do
          Timex.now()
          |> Timex.shift(days: -days_ago)
        end

      [most_recent, _, _, streak_starter, _] =
        for time <- achievement_insertion_times do
          achievement_fixture(activity: activity, inserted_at: time)
        end

      {:range, %{start: start_date, end: end_date}} = Activities.active_streak(activity)
      assert start_date  == streak_starter.inserted_at
      assert end_date  == most_recent.inserted_at
    end

    test "sum_scores_since/3 returns the sum of all `%AchievementLevel{}` `value`s, taking only the highest value per day" do
      alias FluidHabits.AchievementLevelsFixtures

      activity = activity_fixture()

      achievement_levels =
        [level_one, level_two, _level_three] =
        for value <- 1..3 do
          AchievementLevelsFixtures.achievement_level_fixture(activity: activity, value: value)
        end

      [one_day_ago, two_days_ago, three_days_ago] =
        for days_ago <- 1..3 do
          Timex.now()
          |> Timex.shift(days: -days_ago)
        end

      _today_achievement = achievement_fixture(activity: activity, achievement_level: level_one)

      _one_day_ago_achievements =
        for ach_lvl <- achievement_levels do
          achievement_fixture(
            activity: activity,
            achievement_level: ach_lvl,
            inserted_at: one_day_ago
          )
        end

      _two_days_ago_achievements =
        for ach_lvl <- [level_one, level_two, level_two] do
          achievement_fixture(
            activity: activity,
            achievement_level: ach_lvl,
            inserted_at: two_days_ago
          )
        end

      _three_days_ago_achievements =
        for ach_lvl <- [level_one, level_one] do
          achievement_fixture(
            activity: activity,
            achievement_level: ach_lvl,
            inserted_at: three_days_ago
          )
        end

      assert 7 == Activities.sum_scores_since(activity, Timex.beginning_of_day(three_days_ago))
    end

    test "create_activity/1 with invalid data returns error changeset", %{valid_user: valid_user} do
      assert {:error, %Ecto.Changeset{}} = Activities.create_activity(valid_user, @invalid_attrs)
    end

    test "update_activity/2 with valid data updates the activity" do
      activity = activity_fixture()
      update_attrs = %{description: "some updated description", name: "some updated name"}

      assert {:ok, %Activity{} = activity} = Activities.update_activity(activity, update_attrs)
      assert activity.description == "some updated description"
      assert activity.name == "some updated name"
    end

    test "update_activity/2 with invalid data returns error changeset" do
      activity = activity_fixture()
      assert {:error, %Ecto.Changeset{}} = Activities.update_activity(activity, @invalid_attrs)
      assert activity == Activities.get_activity!(activity.id)
    end

    test "delete_activity/1 deletes the activity" do
      activity = activity_fixture()
      assert {:ok, %Activity{}} = Activities.delete_activity(activity)
      assert_raise Ecto.NoResultsError, fn -> Activities.get_activity!(activity.id) end
    end

    test "change_activity/1 returns a activity changeset" do
      activity = activity_fixture()
      assert %Ecto.Changeset{} = Activities.change_activity(activity)
    end

    test "eligible_for_achievements?/1 returns true when there are 3 or more achievement levels associated" do
      activity = activity_fixture()

      Enum.each(1..3, fn _ ->
        FluidHabits.AchievementLevelsFixtures.achievement_level_fixture(%{activity: activity})
      end)

      assert Activities.eligible_for_achievements?(activity) == true
    end

    test "eligible_for_achievements?/1 returns false when there are < 3 achievement levels associated" do
      activity = activity_fixture()

      Enum.each(1..2, fn _ ->
        FluidHabits.AchievementLevelsFixtures.achievement_level_fixture(%{activity: activity})
      end)

      refute Activities.eligible_for_achievements?(activity)
    end
  end
end
