defmodule Mpct.Module do
  @callback init :: :ok | {:error, String.t}
  @callback invoke(String.t) :: {:ok, String.t} | {:error, String.t}
end
