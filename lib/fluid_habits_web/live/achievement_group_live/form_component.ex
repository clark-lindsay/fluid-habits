defmodule FluidHabitsWeb.AchievementGroupLive.FormComponent do
  use FluidHabitsWeb, :live_component

  alias FluidHabits.Achievements
  alias FluidHabits.Achievements.Group

  @impl Phoenix.LiveComponent
  def update(%{activity: activity} = assigns, socket) do
    changeset = Group.changeset(%Group{}, %{activity_id: activity.id})

    achievement_levels = FluidHabits.Activities.list_achievement_levels(activity)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:achievement_levels, achievement_levels)
     |> assign(:changeset, changeset)}
  end

  @impl Phoenix.LiveComponent
  def handle_event("validate", %{"group" => group_params}, socket) do
    changeset =
      %Group{}
      |> Group.changeset(Map.put(group_params, "activity_id", socket.assigns.activity.id))
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  @impl Phoenix.LiveComponent
  def handle_event("save", %{"group" => group_params}, socket) do
    selected_ach_lvl_ids =
      if is_list(group_params["achievement_level_ids"]) do
        Enum.map(group_params["achievement_level_ids"], &String.to_integer/1)
      else
        []
      end

    case group_params
         |> Map.put("activity_id", socket.assigns.activity.id)
         |> Map.put("achievement_level_ids", selected_ach_lvl_ids)
         |> Achievements.create_group() do
      {:ok, _group} ->
        {:noreply,
         socket
         |> put_flash(:info, "Achievement Group created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~H"""
    <div>
      <.form
        :let={f}
        for={@changeset}
        id="achievement-group-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.form_field type="text_input" form={f} field={:name} placeholder="name" />

        <.form_field type="text_input" form={f} field={:description} placeholder="description" />

        <.form_field
          type="checkbox_group"
          form={f}
          field={:achievement_level_ids}
          label="Achievement Levels to include"
          options={Enum.map(@achievement_levels, fn %{name: name, id: id} -> {name, id} end)}
        />

        <.submit_button label="Save" phx_disable_with="Saving..." />
      </.form>
    </div>
    """
  end
end
