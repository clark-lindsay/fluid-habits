defmodule FluidHabitsWeb.AchievementLive.FormComponent do
  use FluidHabitsWeb, :live_component

  import FluidHabitsWeb.Components.FormComponents

  alias FluidHabits.Achievements
  alias FluidHabits.Achievements.Achievement

  @impl Phoenix.LiveComponent
  def update(%{activity: activity} = assigns, socket) do
    achievement = %Achievement{}
    changeset = Achievement.changeset(achievement, %{activity_id: activity.id})

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:achievement, achievement)
     |> assign(:changeset, changeset)}
  end

  @impl Phoenix.LiveComponent
  def handle_event("validate", %{"achievement" => achievement_params}, socket) do
    changeset =
      socket.assigns.achievement
      |> Achievement.changeset(achievement_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  @impl Phoenix.LiveComponent
  def handle_event("save", %{"achievement" => achievement_params}, socket) do
    case Achievements.create_achievement(
           Map.put(achievement_params, "activity_id", socket.assigns.activity.id)
         ) do
      {:ok, _achievement_} ->
        {:noreply,
         socket
         |> put_flash(:info, "Achievement created successfully")
         |> push_patch(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~H"""
    <div>
      <.form
        let={f}
        for={@changeset}
        id="achievement-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.form_field
          type="select"
          form={f}
          field={:achievement_level_id}
          options={@achievement_levels}
        />

        <.submit_button label="Save" phx_disable_with="Saving..." />
      </.form>
    </div>
    """
  end
end
