defmodule FluidHabitsWeb.Components.AchievementComponents do
  use Phoenix.Component

  def to_list_item(assigns) do
    display_datetime =
      DateTime.shift_zone!(assigns.achievement.inserted_at, assigns.timezone)
      |> Timex.format!("{WDshort} {M}-{D} {h24}:{m}")

    ~H"""
    <li>
      <span>
        <%= "#{@achievement.achievement_level.name} (#{@achievement.achievement_level.value}) @ #{display_datetime}" %>
      </span>
    </li>
    """
  end
end
