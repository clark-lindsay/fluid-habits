defmodule FluidHabits.AchievementsTest do
  use FluidHabits.DataCase, async: true

  alias FluidHabits.Achievements
  alias FluidHabits.Achievements.Achievement
  alias FluidHabits.{ActivitiesFixtures, Activities, AchievementLevelsFixtures}

  describe "achievements" do
    setup do
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

    test "create_achievement/1 with valid data creates a achievement",
         %{achievement_level: achievement_level, activity: activity} do
      valid_attrs = %{achievement_level_id: achievement_level.id, activity_id: activity.id}

      assert {:ok, %Achievement{}} = Achievements.create_achievement(valid_attrs)
    end

    test "create_achievement/1 errors when the associated activity is not eligible for achievements" do
      activity = ActivitiesFixtures.activity_fixture()

      achievement_level =
        AchievementLevelsFixtures.achievement_level_fixture(%{activity: activity})

      assert {:error, _} =
               Achievements.create_achievement(%{
                 achievement_level_id: achievement_level.id,
                 activity_id: activity.id
               })
    end
  end
end
