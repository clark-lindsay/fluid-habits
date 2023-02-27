defmodule FluidHabitsWeb.UserSettingsController do
  use FluidHabitsWeb, :controller

  alias FluidHabits.Accounts
  alias FluidHabitsWeb.UserAuth

  plug :assign_email_and_password_changesets
  plug :assign_timezone_changeset

  def edit(conn, _params) do
    render(conn, "edit.html")
  end

  def update(conn, %{"action" => "update_email"} = params) do
    %{"current_password" => password, "user" => user_params} = params
    user = conn.assigns.current_user
    user_token = get_session(conn, :user_token)

    case Accounts.apply_user_email(user, password, user_params) do
      {:ok, applied_user} ->
        Accounts.deliver_update_email_instructions(
          applied_user,
          user.email,
          fn _ -> url(~p"/users/settings/confirm_email/#{user_token}") end
        )

        conn
        |> put_flash(
          :info,
          "A link to confirm your email change has been sent to the new address."
        )
        |> redirect(to: ~p"/users/settings")

      {:error, changeset} ->
        render(conn, "edit.html", email_changeset: changeset)
    end
  end

  def update(conn, %{"action" => "update_password"} = params) do
    %{"current_password" => password, "user" => user_params} = params
    user = conn.assigns.current_user

    case Accounts.update_user_password(user, password, user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Password updated successfully.")
        |> put_session(:user_return_to, ~p"/users/settings")
        |> UserAuth.log_in_user(user)

      {:error, changeset} ->
        render(conn, "edit.html", password_changeset: changeset)
    end
  end

  def update(conn, %{"action" => "update_timezone"} = params) do
    %{"user" => user_params} = params
    user = conn.assigns.current_user

    case Accounts.update_user_timezone(user, user_params) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "Timezone updated successfully.")
        |> redirect(to: ~p"/users/settings")

      {:error, changeset} ->
        render(conn, "edit.html", timezone_changeset: changeset)
    end
  end

  def confirm_email(conn, %{"token" => token}) do
    case Accounts.update_user_email(conn.assigns.current_user, token) do
      :ok ->
        conn
        |> put_flash(:info, "Email changed successfully.")
        |> redirect(to: ~p"/users/settings")

      :error ->
        conn
        |> put_flash(:error, "Email change link is invalid or it has expired.")
        |> redirect(to: ~p"/users/settings")
    end
  end

  defp assign_email_and_password_changesets(conn, _opts) do
    user = conn.assigns.current_user

    conn
    |> assign(:email_changeset, Accounts.change_user_email(user))
    |> assign(:password_changeset, Accounts.change_user_password(user))
  end

  defp assign_timezone_changeset(conn, _opts) do
    user = conn.assigns.current_user

    assign(conn, :timezone_changeset, Accounts.User.timezone_changeset(user, %{}))
  end
end
