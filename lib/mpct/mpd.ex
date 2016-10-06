defmodule Mpct.Mpd do
  use Connection
  use LabeledLogger, label: "Mpd"
  alias Mpct.Marantz.Status

  @initial_state %{
    socket: nil
  }

  @config Application.get_env(:mpct, Mpct.Mpd)
  @host   @config |> Keyword.get(:host) |> to_char_list
  @port   @config |> Keyword.get(:port)

  def start_link do
    Connection.start_link(__MODULE__, @initial_state, name: __MODULE__)
  end

  def init(state) do
    {:connect, nil, state}
  end

  def connect(_info, state) do
    debug "connecting #{@host |> inspect} #{@port |> inspect}"

    case :gen_tcp.connect(@host, @port, [:list, active: :once]) do
      {:ok, socket} ->
        debug "connected."
        {:ok, %{state | socket: socket}}
      {:error, reason} ->
        warn "MPD connection error: #{inspect reason}"
        {:backoff, 1000, state}  # try again in one second
    end
  end

  def status, do: call 'status', [transform_fn: &parse_status/1]

  def call(cmd, opts \\ []) do
    GenServer.call(__MODULE__, {cmd, opts})
  end


  def handle_call({cmd, opts}, _from, state = %{socket: socket}) do
    debug "handle_call #{cmd |> inspect}..."

    :ok = :gen_tcp.send(socket, "#{cmd}\n")

    {:ok, msg} = :gen_tcp.recv(socket, 0)

    if func = Keyword.get(opts, :transform_fn) do
      msg = apply(func, [msg])
    end

    {:reply, msg, state}
  end

  defp parse_status(str) do
    debug "parse_status on: #{str}"
    str
  end
end
