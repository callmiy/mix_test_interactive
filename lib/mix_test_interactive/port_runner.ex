defmodule MixTestInteractive.PortRunner do
  @moduledoc """
  Run the tasks in a new OS process via ports
  """

  @application :mix_test_interactive

  alias MixTestInteractive.Config

  @doc """
  Run tests using the runner from the config.
  """
  def run(%Config{} = config) do
    with {:ok, command} <- build_task_command(config) do
      case :os.type() do
        {:win32, _} ->
          System.cmd("cmd", ["/C", "set MIX_ENV=test&& mix test"], into: IO.stream(:stdio, :line))

        _ ->
          Path.join(:code.priv_dir(@application), "zombie_killer")
          |> System.cmd(["sh", "-c", command], into: IO.stream(:stdio, :line))
      end

      :ok
    end
  end

  @doc """
  Build a shell command that runs the desired mix task(s).

  Colour is forced on- normally Elixir would not print ANSI colours while
  running inside a port.
  """
  def build_task_command(%Config{} = config) do
    with {:ok, cli_args} <- Config.cli_args(config) do
      args = Enum.join(cli_args, " ")

      ansi =
        case Enum.member?(cli_args, "--no-start") do
          true -> "run --no-start -e 'Application.put_env(:elixir, :ansi_enabled, true);'"
          false -> "run -e 'Application.put_env(:elixir, :ansi_enabled, true);'"
        end

      command =
        ["mix", "do", ansi <> ",", config.task, args]
        |> Enum.filter(& &1)
        |> Enum.join(" ")
        |> (fn command -> "MIX_ENV=test #{command}" end).()
        |> String.trim()

      {:ok, command}
    end
  end
end
