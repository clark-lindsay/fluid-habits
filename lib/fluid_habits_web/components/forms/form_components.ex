defmodule FluidHabitsWeb.Components.FormComponents do
  use Phoenix.Component
  import Phoenix.HTML.Form

  def submit_button(assigns) do
    assigns =
      assigns
      |> assign(:class, assigns[:class] || "")
      |> assign(:label, assigns[:label] || "Submit")
      |> assign(:phx_disable_with, assigns[:phx_disable_with] || "Submitting...")

    ~H"""
    <%= submit(@label,
      phx_disable_with: @phx_disable_with,
      class: "my-2 px-4 py-1 bg-primary-500 hover:bg-primary-600 text-white rounded-lg #{@class}"
    ) %>
    """
  end
end
