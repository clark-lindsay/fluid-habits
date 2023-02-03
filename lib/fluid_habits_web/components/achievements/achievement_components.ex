defmodule FluidHabitsWeb.Components.AchievementComponents do
  use Phoenix.Component

  def to_list_item(assigns) do
    display_datetime =
      DateTime.shift_zone!(assigns.achievement.inserted_at, assigns.timezone)
      |> Timex.format!("{WDshort} {M}-{D} {h24}:{m}")

    # important to write the entire utility class name out so that tailwind does not
    # optimize the bundle by removing the custom colors from the theme
    # e.g. using `class={"text-#{color_variable}-500"}` could result in missing colors
    achievement_level_classname =
      case assigns[:achievement].achievement_level.value do
        1 -> "text-achievementLevelLow-500"
        2 -> "text-achievementLevelMedium-500"
        3 -> "text-achievementLevelHigh-500"
        _ -> "text-black"
      end

    assigns =
      assign(assigns,
        display_datetime: display_datetime,
        achievement_level_classname: achievement_level_classname
      )

    ~H"""
    <li>
      <div>
        <span class={@achievement_level_classname}>
          <%= "(#{@achievement.achievement_level.value})" %>
        </span>
        <span><%= "#{@achievement.achievement_level.name}" %></span>
        <span><%= "@ #{@display_datetime}" %></span>
      </div>
    </li>
    """
  end
end
