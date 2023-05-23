defmodule FluidHabitsWeb.UserSettingsLive do
  @moduledoc false
  use FluidHabitsWeb, :live_view

  alias FluidHabits.Accounts
  alias FluidHabitsWeb.Components.Forms.Inputs

  def render(assigns) do
    ~H"""
    <.header>Change Email</.header>

    <.simple_form
      for={@email_form}
      id="email_form"
      phx-submit="update_email"
      phx-change="validate_email"
    >
      <.input field={@email_form[:email]} type="email" label="Email" required />
      <.input
        field={@email_form[:current_password]}
        name="current_password"
        id="current_password_for_email"
        type="password"
        label="Current password"
        value={@email_form_current_password}
        required
      />
      <:actions>
        <.core_button phx-disable-with="Changing..." class="w-full">
          Change Email
        </.core_button>
      </:actions>
    </.simple_form>

    <.header>Change Password</.header>

    <.simple_form
      for={@password_form}
      id="password_form"
      action={~p"/users/log_in?_action=password_updated"}
      method="post"
      phx-change="validate_password"
      phx-submit="update_password"
      phx-trigger-action={@trigger_submit}
    >
      <.input field={@password_form[:email]} type="hidden" value={@current_email} />
      <.input field={@password_form[:password]} type="password" label="New password" required />
      <.input
        field={@password_form[:password_confirmation]}
        type="password"
        label="Confirm new password"
      />
      <.input
        field={@password_form[:current_password]}
        name="current_password"
        type="password"
        label="Current password"
        id="current_password_for_password"
        value={@current_password}
        required
      />
      <:actions>
        <.core_button type="submit" phx-disable-with="Changing..." class="w-full">
          Change Password
        </.core_button>
      </:actions>
    </.simple_form>

    <.header>Change Timezone</.header>

    <.simple_form
      for={@timezone_form}
      id="timezone_form"
      phx-change="validate_timezone"
      phx-submit="update_timezone"
    >
      <.input
        field={@timezone_form[:timezone]}
        name="timezone"
        type="select"
        label="Timezone"
        id="timezone_input"
        options={Inputs.timezone_options()}
        value={@current_user.timezone}
        required
      />

      <:actions>
        <.core_button type="submit" phx-disable-with="Changing timezone..." class="w-full">
          Change timezone
        </.core_button>
      </:actions>
    </.simple_form>
    """
  end

  def mount(%{"token" => token}, _session, socket) do
    socket =
      case Accounts.update_user_email(socket.assigns.current_user, token) do
        :ok ->
          put_flash(socket, :info, "Email changed successfully.")

        :error ->
          put_flash(socket, :error, "Email change link is invalid or it has expired.")
      end

    {:ok, push_navigate(socket, to: ~p"/users/settings")}
  end

  def mount(_params, _session, socket) do
    user = socket.assigns.current_user
    email_changeset = Accounts.change_user_email(user)
    password_changeset = Accounts.change_user_password(user)
    timezone_changeset = Accounts.User.timezone_changeset(user, %{})

    socket =
      socket
      |> assign(:current_password, nil)
      |> assign(:email_form_current_password, nil)
      |> assign(:current_email, user.email)
      |> assign(:email_form, to_form(email_changeset))
      |> assign(:password_form, to_form(password_changeset))
      |> assign(:timezone_form, to_form(timezone_changeset))
      |> assign(:trigger_submit, false)

    {:ok, socket}
  end

  def handle_event("validate_email", params, socket) do
    %{"current_password" => password, "user" => user_params} = params

    email_form =
      socket.assigns.current_user
      |> Accounts.change_user_email(user_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, email_form: email_form, email_form_current_password: password)}
  end

  def handle_event("update_email", params, socket) do
    %{"current_password" => password, "user" => user_params} = params
    user = socket.assigns.current_user

    case Accounts.apply_user_email(user, password, user_params) do
      {:ok, applied_user} ->
        Accounts.deliver_user_update_email_instructions(
          applied_user,
          user.email,
          &url(~p"/users/settings/confirm_email/#{&1}")
        )

        info = "A link to confirm your email change has been sent to the new address."
        {:noreply, socket |> put_flash(:info, info) |> assign(email_form_current_password: nil)}

      {:error, changeset} ->
        {:noreply, assign(socket, :email_form, to_form(Map.put(changeset, :action, :insert)))}
    end
  end

  def handle_event("validate_password", params, socket) do
    %{"current_password" => password, "user" => user_params} = params

    password_form =
      socket.assigns.current_user
      |> Accounts.change_user_password(user_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, password_form: password_form, current_password: password)}
  end

  def handle_event("update_password", params, socket) do
    %{"current_password" => password, "user" => user_params} = params
    user = socket.assigns.current_user

    case Accounts.update_user_password(user, password, user_params) do
      {:ok, user} ->
        password_form =
          user
          |> Accounts.change_user_password(user_params)
          |> to_form()

        {:noreply, assign(socket, trigger_submit: true, password_form: password_form)}

      {:error, changeset} ->
        {:noreply, assign(socket, password_form: to_form(changeset))}
    end
  end

  def handle_event("validate_timezone", params, socket) do
    timezone_form =
      socket.assigns.current_user
      |> Accounts.User.timezone_changeset(params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, timezone_form: timezone_form)}
  end

  def handle_event("update_timezone", params, socket) do
    user = socket.assigns.current_user

    case Accounts.update_user_timezone(user, params) do
      {:ok, user} ->
        {:noreply,
         socket
         |> assign(:current_user, user)
         |> put_flash(:info, "Timezone updated successfully.")}

      {:error, changeset} ->
        {:noreply, assign(socket, :timezone_form, to_form(Map.put(changeset, :action, :insert)))}
    end
  end
end
