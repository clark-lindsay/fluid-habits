defmodule FluidHabitsWeb.Components.ActivityComponents do
  @moduledoc false
  use FluidHabitsWeb, :html

  def activity_card(%{activity: _activity, streak_includes_today?: streak_includes_today?, timezone: timezone} = assigns) do
    assigns = assign(assigns, :show_name, assigns[:show_name] || false)

    shift = fn datetime ->
      datetime |> DateTime.shift_zone!(timezone) |> DateTime.to_date()
    end

    {active_streak_start, running_streak} =
      case assigns[:active_streak] do
        {:range, %{start: streak_start}} ->
          streak_start = shift.(streak_start)

          start_now_diff_in_days =
            timezone
            |> Timex.now()
            |> Timex.to_date()
            |> Timex.diff(streak_start, :days)

          {streak_start,
           if streak_includes_today? do
             1 + start_now_diff_in_days
           else
             start_now_diff_in_days
           end}

        {:single, streak_start} ->
          streak_start = shift.(streak_start)

          {streak_start, 1}

        _ ->
          dashes = for _ <- Range.new(1, String.length("#{assigns.weekly_score}")), into: "", do: "-"

          {"No Active Streak", dashes}
      end

    running_streak_class_name =
      case streak_includes_today? do
        true -> "text-white font-semibold border-transparent bg-primary-600"
        false -> "text-gray-700 border-primary-600"
        _ -> "text-gray-400 border-gray-400 dark:border-gray-50"
      end

    assigns =
      assigns
      |> assign(:class, assigns[:class] || "")
      |> assign(:score_classes, "w-12 text-center dark:text-gray-50 p-3 border-2 rounded-md")
      |> assign(:running_streak, running_streak)
      |> assign(:active_streak_start, active_streak_start)
      |> assign(:running_streak_class_name, running_streak_class_name)

    ~H"""
    <.card class={"min-w-64 #{@class}"}>
      <.card_content>
        <div :if={@show_name} class="pb-3">
          <.link
            navigate={~p"/activities/#{@activity.id}"}
            class="text-xl font-medium text-gray-900 dark:text-white underline decoration-secondary-400 hover:text-secondary-400 hover:decoration-gray-500 dark:hover:decoration-white"
          >
            <%= @activity.name %>
          </.link>
        </div>
        <div class="flex flex-col gap-1">
          <div class="flex justify-between">
            <div class="text-primary-600">
              Streak:
              <div class="text-xs text-gray-400 dark:text-gray-50 pl-2">
                Since: <%= @active_streak_start %>
              </div>
            </div>
            <div class={[@score_classes, @running_streak_class_name]}>
              <%= @running_streak %>
            </div>
          </div>

          <div class="flex justify-between">
            <div>
              <div class="text-primary-600">
                Weekly Score:
                <div class="text-xs text-gray-400 dark:text-gray-50 pl-2">
                  Since: <%= DateTime.to_date(@start_of_week) %>
                </div>
              </div>
            </div>
            <div class={[
              @score_classes,
              "text-gray-700 font-semibold border-gray-700 dark:border-gray-50"
            ]}>
              <%= @weekly_score %>
            </div>
          </div>
        </div>
      </.card_content>
    </.card>
    """
  end
end
