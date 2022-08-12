defmodule FluidHabitsWeb.AchievementLevelLive.AchievementLevel do
  use Phoenix.Component

  def to_list_item(assigns) do
    ~H"""
    <li>
      <strong><%= @ach_lvl.name %></strong>
      <div><%= @ach_lvl.description %></div>
    </li>
    """
  end
end
