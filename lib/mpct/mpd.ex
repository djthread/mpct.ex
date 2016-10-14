defmodule Mpct.Mpd do
  use Connection
  use LabeledLogger, label: "Mpd"
  alias Mpct.{Mpd, Mpd.Status}

  @initial_state %{
    host:    nil,
    port:    nil,
    socket:  nil,
    version: nil
  }

  def start_link(host, port) do
    state = %{@initial_state | host: host, port: port}
    Connection.start_link(__MODULE__, state, name: __MODULE__)
  end

  def init(state) do
    {:connect, nil, state}
  end

  def connect(_info, state = %{host: host, port: port}) do
    debug "Connecting #{host |> inspect} #{port |> inspect}"

    case :gen_tcp.connect(host, port, [:list, active: :false]) do
      {:ok, socket} ->
        debug "Connected."
        {:ok, version} = :gen_tcp.recv(socket, 0)
        {:ok, %{state | socket: socket, version: version}}
      {:error, reason} ->
        warn "MPD connection error: #{inspect reason}"
        {:backoff, 1000, state}  # try again in one second
    end
  end

  def status, do: call 'status', [transform_fn: &Status.parse/1]

  def call(command, opts \\ [])
  def call({:find_album, album}, opts) do
    {:ok, lines} = call("find album #{album}")
    lines |> Mpd.File.parse_files
  end
  def call(cmd, opts) do
    GenServer.call(__MODULE__, {cmd, opts})
  end


  def handle_call({cmd, opts}, _from, state = %{socket: socket}) do
    debug "handle_call #{cmd |> inspect}..."

    :ok = :gen_tcp.send(socket, "#{cmd}\n")

    {:ok, msg} = do_recv(socket)

    case msg
      |> String.split("\n", trim: true)
      |> process
    do
      {:ok, msg} ->
        msg =
          case Keyword.get(opts, :transform_fn) do
            nil  -> msg
            func -> apply(func, [msg])
          end

        {:reply, {:ok, msg}, state}

      {:error, thing, command, message} ->
        {:reply, {:error, "[#{thing}] {#{command}} #{message}"}, state}

    end
  end

  defp process(lines) do
    [status | tail] = lines |> Enum.reverse

    case status do
      "OK" ->
        {:ok, tail |> Enum.reverse}

      "ACK " <> stuff ->
        [_, thing, command, message] =
          ~r/\[(\d+@\d+)\] \{([^}]*)\} (.+)$/
          |> Regex.run(stuff)

        {:error, thing, command, message}
    end
  end

  defp do_recv(socket, str \\ "") do
    with false <- ~r/(OK|ACK .+)\n$/ |> Regex.match?(str),
      {:ok, new_str} <- :gen_tcp.recv(socket, 0)
    do
      do_recv(socket, str <> to_string(new_str))
    else
      true -> {:ok, str}
    end
  end

end
