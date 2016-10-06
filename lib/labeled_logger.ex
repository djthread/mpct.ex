defmodule LabeledLogger do
  defmacro __using__(label: label) do
    quote do
      require Logger
      defp info(str),  do: Logger.info  "#{unquote(label)}: #{str}"
      defp warn(str),  do: Logger.warn  "#{unquote(label)}: #{str}"
      defp debug(str), do: Logger.debug "#{unquote(label)}: #{str}"
    end
  end
end
