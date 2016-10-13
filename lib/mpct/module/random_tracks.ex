defmodule Mpct.Module.RandomTracks do
  use Mpct.Module, label: "RandomTracks"
  alias Mpct.Mpd

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
      |> Enum.map(&Regex.replace(~r/^Album: /, &1, ""))
      |> Enum.filter(&(&1 != ""))

    %{state | albums: albums}
  end
end
