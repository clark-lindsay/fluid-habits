defmodule FluidHabitsWeb.Components.AchievementLevelComponents do
  @moduledoc false
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
