defmodule FluidHabits.AchievementsTest do
  use FluidHabits.DataCase, async: true

  alias FluidHabits.Achievements
  alias FluidHabits.Achievements.Achievement

  describe "achievements" do
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
      achievement = achievement_fixture(context) |> Map.delete(:activity)

      assert Achievements.list_achievements() |> Enum.map(&Map.delete(&1, :activity)) == [
               achievement
             ]
    end

    test "get_achievement!/1 returns the achievement with given id",
         %{achievement_level: _, activity: _} = context do
      achievement = achievement_fixture(context) |> Map.delete(:activity)

      assert Achievements.get_achievement!(achievement.id) |> Map.delete(:activity) == achievement
    end

    test "create_achievement/1 with valid data creates a achievement",
         %{achievement_level: achievement_level, activity: activity} do
      valid_attrs = %{achievement_level_id: achievement_level.id, activity_id: activity.id}

      assert {:ok, %Achievement{}} = Achievements.create_achievement(valid_attrs)
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

    test "sum_scores/1 returns the sum of all `%AchievementLevel{}` `value`s, taking only the highest value per day",
         %{activity: activity} do
      alias FluidHabits.AchievementLevelsFixtures

      achievement_levels =
        [level_one, level_two, _level_three] =
        for value <- 1..3 do
          AchievementLevelsFixtures.achievement_level_fixture(activity: activity, value: value)
        end

      [day_one, day_two, day_three] =
        for days_ago <- 1..3 do
          DateTime.utc_now()
          |> Timex.add(Timex.Duration.from_days(-days_ago))
        end

      today_achievement = achievement_fixture(activity: activity, achievement_level: level_one)

      day_one_achievements =
        for ach_lvl <- achievement_levels do
          achievement_fixture(activity: activity, achievement_level: ach_lvl)
          |> Map.put(:inserted_at, day_one)
        end

      day_two_achievements =
        for ach_lvl <- [level_one, level_two, level_two] do
          achievement_fixture(activity: activity, achievement_level: ach_lvl)
          |> Map.put(:inserted_at, day_two)
        end

      day_three_achievements =
        for ach_lvl <- [level_one, level_one] do
          achievement_fixture(activity: activity, achievement_level: ach_lvl)
          |> Map.put(:inserted_at, day_three)
        end

      assert 7 ==
               [
                 [today_achievement],
                 day_one_achievements,
                 day_two_achievements,
                 day_three_achievements
               ]
               |> List.flatten()
               |> Achievements.sum_scores()
    end
  end
end
