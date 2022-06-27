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
    case AchievementLevels.create_achievement_level(
           socket.assigns.activity,
           achivement_level_params
         ) do
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
      <h2><%= @title %></h2>

      <.form
        let={f}
        for={@changeset}
        id="achievement-level-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <%= label(f, :name) %>
        <%= text_input(f, :name) %>
        <%= error_tag(f, :name) %>

        <%= label(f, :description) %>
        <%= text_input(f, :description) %>
        <%= error_tag(f, :description) %>

        <%= label(f, :value) %>
        <%= text_input(f, :value) %>
        <%= error_tag(f, :value) %>

        <div>
          <%= submit("Save", phx_disable_with: "Saving...") %>
        </div>
      </.form>
    </div>
    """
  end
end
