defmodule FluidHabitsWeb.Components.ActivityComponents do
  use FluidHabitsWeb, :component

  def activity_card(%{activity: _activity} = assigns) do
    running_streak =
      case assigns[:active_streak_start] do
        %Date{} = streak_start ->
          Timex.diff(Date.utc_today(), streak_start, :day)

        _ ->
          "--"
      end

    assigns =
      assigns
      |> assign(:class, assigns[:class] || "")
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
