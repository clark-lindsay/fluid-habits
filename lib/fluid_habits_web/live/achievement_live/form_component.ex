defmodule FluidHabitsWeb.AchievementLive.FormComponent do
  use FluidHabitsWeb, :live_component

  alias FluidHabits.Achievements
  alias FluidHabits.Achievements.{Achievement, Level}

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
     |> assign(:form, to_form(changeset))
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

    {:noreply, assign(socket, changeset: changeset, form: to_form(changeset))}
  end

  @impl Phoenix.LiveComponent
  def handle_event("save", %{"achievement" => achievement_params}, socket) do
    params = Map.put(achievement_params, "activity_id", socket.assigns.activity.id)

    changeset =
      %Achievement{}
      |> Achievement.changeset(params)
      |> Map.put(:action, :insert)

    if changeset.valid? do
      case Achievements.create_achievement(params) do
        {:ok, _achievement_} ->
          {:noreply,
           socket
           |> put_flash(:info, "Achievement created successfully")
           |> push_patch(to: socket.assigns.return_to)}

        {:error, reason} ->
          IO.warn(inspect(reason))

          {:noreply,
           socket
           |> put_flash(:error, "Failed to create achievement with error: #{inspect(reason)}")
           |> push_patch(to: socket.assigns.return_to)}
      end
    else
      {:noreply, assign(socket, changeset: changeset, form: to_form(changeset))}
    end
  end

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~H"""
    <div>
      <.simple_form
        for={@form}
        id="achievement-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
          <.input
            field={@form[:group]}
            label="Group"
            type="select"
          options={[{"All", "all"} | Enum.map(@achievement_groups, &{&1.name, &1.id})]}
          />

        <.input
            field={@form[:achievement_level_id]}
            label="Achievement Level"
            type="select"
            options={[
              {"None", nil} | Enum.map(@achievement_level_options, &Level.to_select_option/1)
            ]}
          />

        <Components.Buttons.button type="submit" phx_disable_with="Saving...">
          Save
        </Components.Buttons.button>
      </.simple_form>
    </div>
    """
  end
end
