defmodule Mpct.Module.RandomTracks do
  use Mpct.Module, label: "RandomTracks"

  def invoke({:random_tracks, opts}, state = %{albums: albums}) do
    count = Keyword.get(opts, :count)
    dir   = Keyword.get(opts, :dir)

    files = get_files(count, dir, albums)

    state |> IO.inspect
    {:ok, "Yeap", state}
  end
  def invoke(_, _), do: :unhandled

  defp get_files(count, dir, albums, acc \\ []) do
    :random.seed(:erlang.now)
    file =
      case dir do
        nil ->
          get_file_from_all(albums)
        dir ->
          :tbi
      end
      |> Map.get(

    get_files(count - 1, nil,
  end

  defp get_file_from_all(albums) do
    {:ok, files} = Mpd.call({:find_album, albums |> Enum.take_random(1) |> hd})
    files |> Enum.take_random(1) |> hd |> Map.get(:file)
  end

end
