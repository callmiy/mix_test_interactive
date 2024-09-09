defmodule MixTestInteractive.Command.ToggleClearConsole do
  @moduledoc """
  Toggle clearing console on or off.
  """

  use MixTestInteractive.Command, command: "c", desc: "turn clearing console on/off"

  alias MixTestInteractive.Command
  alias MixTestInteractive.Settings

  @impl Command
  def run(_args, settings) do
    {:ok, Settings.toggle_clear(settings)}
  end
end
