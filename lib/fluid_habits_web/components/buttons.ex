defmodule FluidHabitsWeb.Components.Buttons do
  @moduledoc false
  use Phoenix.Component

  slot(:inner_block, required: true)

  attr :rest, :global,
    default: %{class: "px-4 py-2 bg-primary-500 hover:bg-primary-600 text-white rounded-lg"},
    include: ~w(phx_disable_with)

  def button(assigns) do
    ~H"""
    <button {@rest}>
      <%= render_slot(@inner_block) %>
    </button>
    """
  end
end
