defmodule Mpct.Worker do
  use GenServer
  use LabeledLogger, label: "Interface"
  alias Mpct.Mpd

  @type state :: Map.t
  @type task :: Atom.t | {Atom.t, [String.t]}
  @type ok_and_state :: {:ok, state}
  @type error_and_reason :: {:error, String.t}
  @type ok_or_error :: ok_and_state | error_and_reason

  @initial_state %{
    tasks:  [],
    albums: []
  }

  @modules Application.get_env(:mpct, :modules)

  @spec start_link :: GenServer.on_start
  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: Mpct.Interface)
  end

  @spec init(:ok) :: ok_or_error
  def init(:ok) do
    init_modules(@modules, @initial_state)
  end

  @spec init_modules([Atom.t], state) :: ok_or_error
  defp init_modules([module | tail], state) do
    debug "Init #{module |> to_string}..."
    case apply(module, :init, [state]) do
      {:ok, new_state} -> init_modules(tail, new_state)
      {:error, reason} -> {:error, reason}
    end
  end
  defp init_modules([], state) do
    state = flush_tasks(state)
    debug "Init complete!"

    {:ok, state}
  end

  @spec flush_tasks(state) :: state
  defp flush_tasks(state = %{tasks: [task | tasks]}) do
    state = do_task(task, state)
    %{state | tasks: tasks}
  end
  defp flush_tasks(state = %{tasks: []}) do
    state
  end

  @spec do_task(task, state) :: ok_or_error
  defp do_task(:load_albums, state) do
    debug "Getting album list..."
    with {:ok, albums} <- Mpd.call("list album") do
      albums =
        albums
        |> Enum.map(&Regex.replace(~r/^Album: /, &1, ""))
        |> Enum.filter(&(&1 != ""))

      info "Loaded #{length state.albums} albums"

      {:ok, %{state | albums: albums}}
    end
  end
end
