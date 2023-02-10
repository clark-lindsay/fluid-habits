defmodule FluidHabitsWeb.AchievementLive.FormComponent do
  use FluidHabitsWeb, :live_component

  import FluidHabitsWeb.Components.FormComponents

  alias FluidHabits.Achievements
  alias FluidHabits.AchievementLevels.AchievementLevel
  alias FluidHabits.Achievements.Achievement

  @impl Phoenix.LiveComponent
  def update(%{activity: activity} = assigns, socket) do
    achievement = %Achievement{}
    changeset = Achievement.changeset(achievement, %{activity_id: activity.id})

    achievement_groups =
      FluidHabits.Repo.preload(activity, :achievement_groups).achievement_groups

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:achievement, achievement)
     |> assign(:changeset, changeset)
     |> assign(:achievement_groups, achievement_groups)
     |> assign(:achievement_level_options, assigns.achievement_levels)}
  end

  @impl Phoenix.LiveComponent
  def handle_event(
        "validate",
        %{"achievement" => achievement_params},
        socket
      ) do
    socket =
      case achievement_params["group"] do
        nil ->
          socket

        "all" ->
          assign(socket, :achievement_level_options, socket.assigns.achievement_levels)

        _ ->
          assign(socket,
            achievement_level_options:
              Enum.filter(socket.assigns.achievement_levels, fn ach_lvl ->
                ach_lvl.group_id == String.to_integer(achievement_params["group"])
              end)
          )
      end

    options = Enum.map(socket.assigns.achievement_level_options, & &1.id)

    achievement_params =
      achievement_params
      |> Map.put("activity_id", socket.assigns.activity.id)
      |> Map.update("achievement_level_id", nil, fn
        "" ->
          nil

        id when is_binary(id) ->
          case options do
            [] ->
              nil

            list ->
              if String.to_integer(id) in list, do: id, else: hd(list)
          end

        _ ->
          nil
      end)

    changeset =
      %Achievement{}
      |> Achievement.changeset(achievement_params)
      |> Map.put(:action, :insert)

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

      {:error, reason} ->
        IO.inspect(reason)

        {:noreply,
         socket
         |> put_flash(:error, "Failed to create achievement with error: #{inspect(reason)}")
         |> push_patch(to: socket.assigns.return_to)}
    end
  end

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~H"""
    <div>
      <.form
        :let={f}
        for={@changeset}
        id="achievement-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.form_field
          type="select"
          form={f}
          field={:group}
          options={[{"All", "all"} | Enum.map(@achievement_groups, &{&1.name, &1.id})]}
        />

        <.form_field
          type="select"
          form={f}
          field={:achievement_level_id}
          options={[
            {"None", nil} | Enum.map(@achievement_level_options, &AchievementLevel.to_select_option/1)
          ]}
        />

        <.submit_button label="Save" phx_disable_with="Saving..." />
      </.form>
    </div>
    """
  end
end
