defmodule Mpct.Module do
  alias Mpct.Worker

  @callback init(Worker.state) ::
    {:ok, Worker.state} | {:error, String.t}
  @callback invoke(String.t, Worker.state) ::
    {:ok, String.t} | {:error, String.t}

  defmacro __using__(label: label) do
    quote do
      @behaviour Mpct.Module
      use LabeledLogger, label: unquote(label)

      def init(state), do: {:ok, state}

      defoverridable init: 1
    end
  end
end
