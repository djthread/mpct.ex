defmodule Mpct.Mpd.File do
  alias Mpct.Mpd.File

  defstruct [:file, :last_modified, :time, :artist,
             :album, :title, :track, :date]

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
      end

    {current, files} =
      case file_key do
        :file ->
          {%File{file: value}, files ++ [current]}
        _ ->
          {Map.put(current, file_key, value), files}
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
