defmodule FluidHabitsWeb.AchievementLive.FormComponent do
  use FluidHabitsWeb, :live_component

  alias FluidHabits.Achievements
  alias FluidHabits.Achievements.Achievement

  @impl Phoenix.LiveComponent
  def update(%{activity: activity} = assigns, socket) do
    achievement = %Achievement{}
    changeset = Achievements.change_achievement(achievement, %{activity_id: activity.id})

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
      |> Achievements.change_achievement(achievement_params)
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
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~H"""
    <div>
      <h2><%= @title %></h2>

      <.form
        let={f}
        for={@changeset}
        id="achievement-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <%= select(f, :achievement_level_id, @achievement_levels) %>

        <div>
          <%= submit("Save", phx_disable_with: "Saving...") %>
        </div>
      </.form>
    </div>
    """
  end
end
