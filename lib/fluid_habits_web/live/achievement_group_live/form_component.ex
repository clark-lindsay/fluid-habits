defmodule FluidHabitsWeb.AchievementGroupLive.FormComponent do
  use FluidHabitsWeb, :live_component

  alias FluidHabits.Achievements
  alias FluidHabits.Achievements.Group

  @impl Phoenix.LiveComponent
  def update(%{activity: activity} = assigns, socket) do
    changeset = Group.changeset(%Group{}, %{activity_id: activity.id})

    import Ecto.Query, only: [from: 2]

    achievement_levels =
      FluidHabits.Activities.list_achievement_levels(activity)
      |> FluidHabits.Repo.preload(group: from(g in Group, select: %{name: g.name}))

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:confirmed_ach_lvl_ids_to_change, [])
     |> assign(:has_confirmed_group_membership_changes, false)
     |> assign(:achievement_levels, achievement_levels)
     |> assign(:changeset, changeset)}
  end

  @impl Phoenix.LiveComponent
  def handle_event("confirm_group_membership_changes", %{"ids" => ids}, socket) do
    new_selections = String.split(ids, ",") |> Enum.map(&String.to_integer/1)

    {:noreply,
     socket
     |> assign(:confirmed_ach_lvl_ids_to_change, new_selections)
     |> assign(:has_confirmed_group_membership_changes, true)}
  end

  @impl Phoenix.LiveComponent
  def handle_event("validate", %{"group" => group_params}, socket) do
    achievement_level_ids = form_id_list_to_integers(group_params["achievement_level_ids"])

    # see if the selected ach_lvl ids match the ones that the user has already confirmed,
    # and reset the membership confirmation section if they do not
    socket =
      socket
      |> assign(
        :has_confirmed_group_membership_changes,
        Enum.sort(achievement_level_ids) |> Enum.join() ==
          Enum.sort(socket.assigns.confirmed_ach_lvl_ids_to_change) |> Enum.join()
      )

    selected_ach_levels =
      Enum.filter(socket.assigns.achievement_levels, fn ach_lvl ->
        ach_lvl.id in achievement_level_ids
      end)

    params =
      group_params
      |> Map.put("activity_id", socket.assigns.activity.id)
      |> Map.put("achievement_levels", selected_ach_levels)

    changeset =
      %Group{}
      |> Group.changeset(params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  @impl Phoenix.LiveComponent
  def handle_event("save", %{"group" => group_params}, socket) do
    achievement_level_ids = form_id_list_to_integers(group_params["achievement_level_ids"])

    selected_ach_levels =
      Enum.filter(socket.assigns.achievement_levels, fn ach_lvl ->
        ach_lvl.id in achievement_level_ids
      end)

    case group_params
         |> Map.put("activity_id", socket.assigns.activity.id)
         |> Map.put("achievement_levels", selected_ach_levels)
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
        <.form_field_error form={f} field={:achievement_levels} class="mt-1" />

        <%= if (@has_confirmed_group_membership_changes) do %>
          <.submit_button label="Save" phx_disable_with="Saving..." />
        <% else %>
          <.h3>Group Membership Changes</.h3>
          <%= for ach_lvl <- @achievement_levels, !is_nil(ach_lvl.group), ach_lvl.id in Enum.map(@changeset.changes.achievement_levels, & &1.data.id) do %>
            <div>
              <%= ach_lvl.name %>: <%= ach_lvl.group.name %> -> <%= @changeset.changes[:name] ||
                "New Group" %>
            </div>
          <% end %>
          <.button
            type="button"
            phx-click="confirm_group_membership_changes"
            phx-value-ids={
              Enum.map(@changeset.changes.achievement_levels, &Integer.to_string(&1.data.id))
              |> Enum.join(",")
              |> URI.encode()
            }
            phx-target={@myself}
            disabled={length(@changeset.changes.achievement_levels) < 1}
            label="Confirm"
            color="primary"
          />
        <% end %>
      </.form>
    </div>
    """
  end

  defp form_id_list_to_integers(ids) when is_list(ids), do: Enum.map(ids, &String.to_integer/1)
  defp form_id_list_to_integers(_), do: []
end
