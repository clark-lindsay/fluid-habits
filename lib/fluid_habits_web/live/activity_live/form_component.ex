defmodule FluidHabitsWeb.ActivityLive.FormComponent do
  use FluidHabitsWeb, :live_component

  alias FluidHabits.Activities
  alias FluidHabits.Activities.Activity

  @impl true
  def update(%{activity: activity} = assigns, socket) do
    changeset = Activity.changeset(activity, %{})

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"activity" => activity_params}, socket) do
    changeset =
      socket.assigns.activity
      |> Activity.changeset(activity_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"activity" => activity_params}, socket) do
    save_activity(socket, socket.assigns.action, activity_params)
  end

  defp save_activity(socket, :edit, activity_params) do
    case Activities.update_activity(socket.assigns.activity, activity_params) do
      {:ok, _activity} ->
        {:noreply,
         socket
         |> put_flash(:info, "Activity updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_activity(socket, :new, activity_params) do
    case Activities.create_activity(socket.assigns.current_user, activity_params) do
      {:ok, _activity} ->
        {:noreply,
         socket
         |> put_flash(:info, "Activity created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
