defmodule FluidHabitsWeb.Components.ActivityComponents do
  use FluidHabitsWeb, :component

  def activity_card(%{activity: _activity, timezone: timezone} = assigns) do
    {active_streak_start, running_streak} =
      case assigns[:active_streak] do
        {:range, %{start: streak_start, end: streak_end}} ->
          streak_start = DateTime.shift_zone!(streak_start, timezone)
          streak_end = DateTime.shift_zone!(streak_end, timezone)
          now = Timex.now(timezone)

          start_now_diff_in_days = Timex.diff(now, streak_start, :days)
          streak_includes_today? = Timex.equal?(now, streak_end, :days)

          {DateTime.to_date(streak_start),
           if streak_includes_today? do
             1 + start_now_diff_in_days
           else
             start_now_diff_in_days
           end}

        {:single, streak_start} ->
          streak_start = DateTime.shift_zone!(streak_start, timezone)

          {DateTime.to_date(streak_start), 1}

        _ ->
          {"No Active Streak", "--"}
      end

    assigns =
      assigns
      |> assign(:class, assigns[:class] || "")
      |> assign(:running_streak, running_streak)
      |> assign(:active_streak_start, active_streak_start)

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
                Since: <%= DateTime.to_date(@start_of_week) %>
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
