defmodule FluidHabitsWeb.AchievementLive.Achievement do
  use Phoenix.Component

  def to_list_item(assigns) do
    ~H"""
    <li>
      <span><%= "#{@achievement.achievement_level.name} @ #{@achievement.inserted_at}" %></span>
    </li>
    """
  end
end
