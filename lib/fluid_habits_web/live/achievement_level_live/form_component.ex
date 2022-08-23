defmodule FluidHabitsWeb.AchievementLevelLive.FormComponent do
  use FluidHabitsWeb, :live_component

  alias FluidHabits.AchievementLevels
  alias FluidHabits.AchievementLevels.AchievementLevel

  @impl Phoenix.LiveComponent
  def update(%{activity: activity} = assigns, socket) do
    achievement_level = %AchievementLevel{}

    changeset =
      AchievementLevels.change_achievement_level(%AchievementLevel{activity_id: activity.id})

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:achievement_level, achievement_level)
     |> assign(:changeset, changeset)}
  end

  @impl Phoenix.LiveComponent
  def handle_event("validate", %{"achievement_level" => achivement_level_params}, socket) do
    changeset =
      socket.assigns.achievement_level
      |> AchievementLevels.change_achievement_level(achivement_level_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  @impl Phoenix.LiveComponent
  def handle_event("save", %{"achievement_level" => achivement_level_params}, socket) do
    case achivement_level_params
         |> Map.put("activity_id", socket.assigns.activity.id)
         |> AchievementLevels.create_achievement_level() do
      {:ok, _achievement_level} ->
        {:noreply,
         socket
         |> put_flash(:info, "Achievement Level created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

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
        id="achievement-level-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.form_field type="text_input" form={f} field={:name} placeholder="name" />

        <.form_field type="text_input" form={f} field={:description} placeholder="description" />

        <.form_field type="select" options={["1": 1, "2": 2, "3": 3]} form={f} field={:value} />

        <%= submit("Save",
          phx_disable_with: "Saving...",
          class: "my-2 px-4 py-1 bg-blue-500 text-white rounded-lg"
        ) %>
      </.form>
    </div>
    """
  end
end
