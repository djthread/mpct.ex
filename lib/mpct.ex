defmodule Mpct do
  use Application
  alias Mpct.{Module, Worker}

  @host Application.get_env(:mpct, :host) |> to_char_list
  @port Application.get_env(:mpct, :port)

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      supervisor(Mpct.Endpoint, []),
      # worker(Mpct.Marantz, []),
      worker(Mpct.Mpd, [@host, @port]),
      worker(Mpct.Worker, [])
    ]

    opts = [strategy: :one_for_one, name: Mpct.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    Mpct.Endpoint.config_change(changed, removed)
    :ok
  end

  @callback invoke(Module.command, Module.parameters, Worker.state) ::
    Module.invoke_return
  def invoke(command, parameters, state) do
    Mpct.Worker.invoke(command, parameters, state)
  end
end
