defmodule Mpct.Worker do
  use GenServer
  use LabeledLogger, label: "Interface"
  alias Mpct.Mpd

  @initial_state %{
    albums: []
  }

  @modules Application.get_env(:mpct, :modules)

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: Mpct.Interface)
  end

  def init(:ok) do
    init_modules(@modules, @initial_state)
  end

  defp init_modules([module | tail], state) do
    debug "Init #{module |> to_string}..."
    case apply(module, :init, [state]) do
      {:ok, new_state} -> init_modules(tail, new_state)
      {:error, reason} -> {:error, reason}
    end
  end
  defp init_modules([], state) do
    debug "Init complete!"
    {:ok, state}
  end
end
