defmodule Mpct.Mpd.File do
  alias Mpct.Mpd.File

  defstruct [
    file:          nil,
    last_modified: nil,
    time:          nil,
    artist:        nil,
    album:         nil,
    title:         nil,
    track:         nil,
    date:          nil,
    genre:         nil,
    album_artist:  nil,
    extra:         %{}
  ]

  def parse_files([line | lines], current \\ %File{}, files \\ []) do
    [_, key, value] = Regex.run(~r/^(.+?): (.*)$/, line)

    file_key =
      case key do
        "file"          -> :file
        "Last-Modified" -> :last_modified
        "Time"          -> :time
        "Artist"        -> :artist
        "Album"         -> :album
        "Title"         -> :title
        "Track"         -> :track
        "Date"          -> :date
        "Genre"         -> :genre
        "AlbumArtist"   -> :album_artists
        label           -> nil
      end

    {current, files} =
      case file_key do
        :file ->
          {%File{file: value}, files ++ [current]}
        _ ->
          case file_key do
            nil ->
              extra = Map.put(current.extra, key, value)
              {Map.put(current, :extra, extra), files}
            fk ->
              {Map.put(current, fk, value), files}
          end
      end

    parse_files(lines, current, files)
  end
  def parse_files([], current, [_ | files]) do
    files ++ [current]
  end
  def parse_files([], current, []) do
    [current]
  end
end
