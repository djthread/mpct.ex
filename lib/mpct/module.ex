defmodule Mpct.Module do
  alias Mpct.Worker

  @type command :: Atom.t | {Atom.t, [String.t]}
  @type invoke_return ::
    {:unknown, Worker.state}
    | {:ok, String.t, Worker.state}
    | {:error, String.t, Worker.state}

  defmacro __using__(label: label) do
    quote do
      use LabeledLogger, label: unquote(label)
      alias Mpct.{Module, Mpd, Worker}

      @behaviour Mpct.Module

      @callback init(Worker.state) ::
        {:ok, Worker.state} | {:error, String.t}
      def init(state), do: {:ok, state}

      @callback invoke(Module.command, Module.parameters, Worker.state) ::
        Module.invoke_return
      def invoke(_command, _params, state), do: {:unknown, state}

      defoverridable init: 1
    end
  end
end
