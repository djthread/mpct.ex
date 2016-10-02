module Api exposing (..)

import Task exposing (..)
import Http
import Json.Decode
import Types exposing (..)


url : Config -> String
url config =
  "http://" ++ config.http_host ++ ":"
    ++ toString config.http_port


status : Config -> Cmd Msg
status config =
  call config "-x status"


call : Config -> String -> Cmd Msg
call config command =
  let
    the_url = url config
    body    = Http.string command
    decoder = Json.Decode.string
  in
    Debug.log "call."
    Http.post decoder the_url body
    |> Task.perform CallFail (CallSucceed command)


update : String -> String -> Model -> Model
update command data model =
  case command of
    "-x status" ->
      Debug.log ("Right -- " ++ data)
      model
    _ ->
      model
