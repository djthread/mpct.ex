defmodule Mpct.Marantz do
  use GenServer
  require Logger

  @initial_state %{}

  @config Application.get_env(:mpct, Mpct.Marantz)
  @host   @config |> Keyword.get(:host)
  @port   @config |> Keyword.get(:port)

  def start_link do
    GenServer.start_link __MODULE__, @initial_state, name: __MODULE__
  end

  def init(state) do
    {:ok, state}
  end

  def call cmd do
    GenServer.call __MODULE__, cmd
  end

  # def toggle_power, do: call :toggle_power
  # def vol(:up),     do: call {vol, :up}
  # def vol(:down),   do: call :down
  # def vol(num),     do: call :down


  def handle_call {"vol", "up"}, _from, state do
    do_send state, 'MVUP'
  end
  def handle_call {"vol", "down"}, _from, state do
    do_send state, 'MVDOWN'
  end
  def handle_call {"vol", num}, _from, state do
    true = num =~ ~r/\d\d/
    do_send state, 'MV' ++ num
  end

  def handle_call {"input", "mobius"}, _from, state do
    do_send state, 'SIBD'
  end
  def handle_call {"input", "optical"}, _from, state do
    do_send state, 'SIDVD'
  end
  def handle_call {"input", "bluray"}, _from, state do
    do_send state, 'SIBD'
  end
  def handle_call {"input", "ccast"}, _from, state do
    do_send state, 'SIMPLAY'
  end
  def handle_call {"input", "mini"}, _from, state do
    do_send state, 'SICD'
  end
  def handle_call "toggle_power", _from, state do
    _do_send 'PW?',
      react_fn: fn(info) ->
        if to_string(info) =~ ~r/PWR:1/ do
          'PWON'
        else
          'PWSTANDBY'
        end
      end

    {:reply, nil, state}
  end
  def handle_call cmd, _, state do
    info "Unrecognized command: #{inspect cmd}"
    {:reply, nil, state}
  end


  defp do_send state, command, opts \\ [] do
    _do_send command, opts

    {:reply, nil, state}
  end

  defp _do_send(command, opts) when is_list(opts) do
    opts = opts
    |> Keyword.put_new(:react_fn, nil)

    debug "connecting #{@host |> inspect} #{@port |> inspect}"

    case :gen_tcp.connect @host, @port, [:list, active: false] do
      {:ok, socket} ->
        :ok = :gen_tcp.send socket, command ++ '\r\n'

        socket =
          if func = Keyword.get opts, :react_fn do
            debug "reading"
            {:ok, msg} = :gen_tcp.recv socket, 0
            if followup_cmd = func.(msg) do
              debug "followup_cmd: #{followup_cmd}"
              :ok = :gen_tcp.close socket
              :timer.sleep 100
              {:ok, socket} = :gen_tcp.connect @host, @port, [:list, active: false]
              :ok = :gen_tcp.send socket, followup_cmd ++ '\r\n'
              socket
            else
              socket
            end
          end

        debug "done"
        :ok = :gen_tcp.close socket

        true

      fail ->
        warn "No good: #{fail |> inspect}"
        false

    end
  end

  defp info(str),  do: Logger.info  "Marantz: #{str}"
  defp warn(str),  do: Logger.warn  "Marantz: #{str}"
  defp debug(str), do: Logger.debug "Marantz: #{str}"
end
