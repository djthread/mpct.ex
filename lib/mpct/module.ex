defmodule Mpct.Module do
  alias Mpct.Worker

  @type command :: String.t | {String.t, Keyword.t}
  @type invoke_return ::
    {:ok, String.t, Worker.state}
    | {:error, String.t, Worker.state}
    | :unhandled

  defmacro __using__(label: label) do
    quote do
      use LabeledLogger, label: unquote(label)
      alias Mpct.{Module, Mpd, Worker}

      @behaviour Mpct.Module

      @callback init(Worker.state) ::
        {:ok, Worker.state} | {:error, String.t}
      def init(state), do: {:ok, state}

      @callback invoke(Module.command, Worker.state) :: Module.invoke_return
      def invoke(_command, state), do: {:unknown, state}

      defoverridable init: 1, invoke: 2
    end
  end
end
