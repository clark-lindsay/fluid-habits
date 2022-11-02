defmodule FluidHabits.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `FluidHabits.Accounts` context.
  """

  def unique_user_email, do: "user#{System.unique_integer()}@example.com"
  def valid_user_password, do: "hello world!"

  def valid_user_attributes(attrs \\ %{}) do
    attrs = Enum.into(attrs, %{})

    Map.merge(
      %{
        email: unique_user_email(),
        password: valid_user_password(),
        timezone: "Etc/UTC"
      },
      attrs
    )
  end

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> valid_user_attributes()
      |> FluidHabits.Accounts.register_user()

    user
  end

  def extract_user_token(fun) do
    {:ok, captured_email} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token | _] = String.split(captured_email.text_body, "[TOKEN]")
    token
  end
end
