defmodule FluidHabitsWeb.Components.ActivityComponents do
  use FluidHabitsWeb, :component

  def activity_card(%{activity: _activity} = assigns) do
    assigns =
      assigns
      |> assign(:class, assigns[:class] || "")

    ~H"""
    <.card class={"w-64 #{@class}"}>
      <.card_content heading={@activity.name}>
        <div class="flex justify-between">
          <div class="text-primary-600">Streak:</div>
          <div class="text-gray-700">{# OF DAYS}</div>
        </div>

        <div class="flex justify-between">
          <div>
            <div class="text-primary-600">Weekly Score:</div>
            <div class="text-xs text-gray-400">
              Since: <%= DateTime.utc_now() |> DateTime.to_date() %>
            </div>
          </div>
          <div class="text-gray-700">{# OF PNTS}</div>
        </div>
      </.card_content>
    </.card>
    """
  end
end
