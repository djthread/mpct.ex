defmodule Mpct.Mpd.Status do
  use LabeledLogger, label: "Mpd.Status"
  alias Mpct.Mpd.Status

  @bits [
    :volume, :repeat, :random, :single, :consume, :playlist, :playlistlength,
    :mixrampdb, :state, :song, :songid, :time, :elapsed, :bitrate, :audio,
    :nextsong, :nextsongid
  ]

  defstruct @bits

  def parse(lines) do
    do_parse(lines, %Status{})
  end

  for bit <- @bits do
    defp do_parse(["#{unquote(bit |> to_string)}: " <> data | tail], st = %Status{}) do
      do_parse(tail, st |> Map.put(unquote(bit), data))
    end
  end

  defp do_parse([unrecognized | tail], st) do
    warn "Unrecognized info: #{unrecognized}"
    do_parse(tail, st)
  end
  defp do_parse([], st) do
    st
  end
end
