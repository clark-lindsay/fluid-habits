defmodule FluidHabitsWeb.Components.AchievementComponents do
  use Phoenix.Component

  def to_list_item(assigns) do
    ~H"""
    <li>
      <span>
        <%= "#{@achievement.achievement_level.name} (#{@achievement.achievement_level.value}) @ #{@achievement.inserted_at}" %>
      </span>
    </li>
    """
  end
end
