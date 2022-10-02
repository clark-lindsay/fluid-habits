defmodule FluidHabitsWeb.Components.ActivityComponents do
  use FluidHabitsWeb, :component

  def activity_card(%{activity: _activity} = assigns) do
    now = NaiveDateTime.utc_now()

    running_streak =
      NaiveDateTime.diff(now, assigns[:active_streak_start] || now)
      |> Integer.floor_div(60 * 60 * 24)

    assigns =
      assigns
      |> assign(:class, assigns[:class] || "")
      |> assign(:active_streak_start, assigns[:active_streak_start] |> NaiveDateTime.to_date())
      |> assign(:running_streak, running_streak)

    ~H"""
    <.card class={"w-64 #{@class}"}>
      <.card_content heading={@activity.name}>
        <div class="flex justify-between">
          <div class="text-primary-600">
            Streak:
            <div class="text-xs text-gray-400 pl-2">
              Since: <%= @active_streak_start %>
            </div>
          </div>
          <div class="text-gray-700">
            <%= @running_streak %>
          </div>
        </div>

        <div class="flex justify-between">
          <div>
            <div class="text-primary-600">
              Weekly Score:
              <div class="text-xs text-gray-400 pl-2">
                Since: <%= @start_of_week %>
              </div>
            </div>
          </div>
          <div class="text-gray-700"><%= @weekly_score %></div>
        </div>
      </.card_content>
    </.card>
    """
  end
end
