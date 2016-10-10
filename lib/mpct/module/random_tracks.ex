defmodule Mpct.Module.RandomTracks do
  use LabeledLogger, label: "RandomTracks"
  alias Mpct.Mpd

  @behaviour Mpct.Module

  def init(state) do
    debug "Getting album list..."
    with {:ok, albums} <- Mpd.call("list album") do
      state = albums |> load_albums(state)
      info "Loaded #{length state.albums} albums"
      {:ok, state}
    end
  end

  defp load_albums(albums, state) do
    albums =
      albums
      |> Enum.map(fn(line) -> Regex.replace(~r/^Album: /, line, "") end)
      |> Enum.filter(fn(album) -> album != "" end)

    %{state | albums: albums}
  end
end
