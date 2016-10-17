defmodule Mpct.Module.RandomTracks do
  use Mpct.Module, label: "RandomTracks"

  def invoke({:random_tracks, opts},
             state = %{albums: albums}) do
    :random.seed(:erlang.now)

    count = Keyword.get(opts, :count, 10)
    dir   = Keyword.get(opts, :dir,   nil)

    files = get_files(count, dir, albums)

    IO.puts "files: #{inspect files}"
    state |> IO.inspect

    {:ok, "Yeap", state}
  end
  def invoke(_, _), do: :unhandled

  defp get_files(count, dir, albums, acc \\ [])
  when count > 0 do
    file =
      case dir do
        nil ->
          get_file_from_all(albums)
        dir ->
          :tbi
      end
      |> Map.get(:file)

    get_files(count - 1, nil, albums, [file | acc])
  end
  defp get_files(_, _, _, acc), do: acc

  defp get_file_from_all(albums) do
    album = albums |> Enum.take_random(1) |> hd

    {:find_album, album}
    |> Mpd.call
    |> Enum.take_random(1)
    |> hd
  end

end
