defmodule FluidHabits.AchievementsTest do
  use FluidHabits.DataCase, async: true

  alias FluidHabits.Achievements

  describe "achievements" do
    alias FluidHabits.Achievements.Achievement

    import FluidHabits.AchievementsFixtures

    setup do
      alias FluidHabits.{ActivitiesFixtures, Activities, AchievementLevelsFixtures}

      activity = ActivitiesFixtures.activity_fixture()

      achievement_level =
        AchievementLevelsFixtures.achievement_level_fixture(%{activity: activity})

      # create additional achievement_levels to meet
      # achievement eligibility requirements
      for _iteration <- Range.new(1, Activities.min_ach_levels_for_ach_eligibility()) do
        AchievementLevelsFixtures.achievement_level_fixture(%{activity: activity})
      end

      %{activity: activity, achievement_level: achievement_level}
    end

    test "list_achievements/0 returns all achievements",
         %{activity: _, achievement_level: _} = context do
      achievement = achievement_fixture(context)

      assert Achievements.list_achievements() == [achievement]
    end

    test "get_achievement!/1 returns the achievement with given id",
         %{achievement_level: _, activity: _} = context do
      achievement = achievement_fixture(context)

      assert Achievements.get_achievement!(achievement.id) == achievement
    end

    test "create_achievement/1 with valid data creates a achievement",
         %{achievement_level: achievement_level, activity: activity} do
      valid_attrs = %{achievement_level_id: achievement_level.id, activity_id: activity.id}

      assert {:ok, %Achievement{}} = Achievements.create_achievement(valid_attrs)
    end

    test "create_achievement/1 starts a streak when one _does not exist_", %{
      achievement_level: achievement_level,
      activity: activity
    } do
      valid_attrs = %{achievement_level_id: achievement_level.id, activity_id: activity.id}

      assert {:ok, %Achievement{streak_start: streak_start}} =
               Achievements.create_achievement(valid_attrs)

      assert NaiveDateTime.to_date(streak_start) == Date.utc_today()
    end

    test "create_achievement/1 extends a streak when one _does exist_", %{
      achievement_level: achievement_level,
      activity: activity
    } do
      valid_attrs = %{achievement_level_id: achievement_level.id, activity_id: activity.id}
      one_week_ago = NaiveDateTime.utc_now() |> NaiveDateTime.add(60 * 60 * 24 * 7 * -1)
      yesterday = NaiveDateTime.utc_now() |> NaiveDateTime.add(60 * 60 * 24 * 1 * -1)

      assert {:ok, _older_achievement = %Achievement{}} =
               valid_attrs
               |> Map.put(:streak_start, one_week_ago)
               |> Achievements.create_achievement()

      assert {:ok, _current_streak_achievement = %Achievement{}} =
               valid_attrs
               |> Map.put(:streak_start, yesterday)
               |> Map.put(:inserted_at, yesterday)
               |> Achievements.create_achievement()

      assert {:ok, newer_achievement = %Achievement{}} =
               Achievements.create_achievement(valid_attrs)

      assert NaiveDateTime.to_date(newer_achievement.streak_start) ==
               NaiveDateTime.to_date(yesterday)
    end

    test "update_achievement/2 with valid data updates the achievement",
         %{achievement_level: _, activity: _} = context do
      achievement = achievement_fixture(context)
      update_attrs = %{}

      assert {:ok, %Achievement{}} = Achievements.update_achievement(achievement, update_attrs)
    end

    test "delete_achievement/1 deletes the achievement",
         %{achievement_level: _, activity: _} = context do
      achievement = achievement_fixture(context)

      assert {:ok, %Achievement{}} = Achievements.delete_achievement(achievement)
      assert_raise Ecto.NoResultsError, fn -> Achievements.get_achievement!(achievement.id) end
    end

    test "change_achievement/1 returns a achievement changeset",
         %{achievement_level: _, activity: _} = context do
      achievement = achievement_fixture(context)

      assert %Ecto.Changeset{} = Achievements.change_achievement(achievement)
    end
  end
end
