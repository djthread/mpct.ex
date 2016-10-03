module Api exposing (..)

import Task exposing (..)
import Http exposing (defaultSettings)
import Http
import Types exposing (..)


url : Config -> String
url config =
  "http://" ++ config.host ++ ":"
    ++ toString config.port'


status : Config -> Cmd Msg
status config =
  call config "-x status"


call : Config -> String -> Cmd Msg
call config command =
  let
    settings = defaultSettings
      -- { defaultSettings
      -- | timeout = 4
      -- }
      -- { timeout = 2
      -- , desiredResponseType : ...
      -- , onProgress : ...
      -- , onStart : ...
      -- , withCredentials : ...
      -- }
    request =
      { verb = "POST"
      , url  = url config
      , body = Http.string command
      , headers = []
      }
    task =
      Http.send settings request
    cmd = 
      task
      |> Task.perform CallFail (CallSucceed command)
  in
    Debug.log ("settings: " ++ toString settings)
    Debug.log ("request: " ++ toString request)
    Debug.log ("task: " ++ toString task)
    Debug.log ("cmd: " ++ toString cmd)
    cmd
    -- Debug.log "call."

    -- Http.post decoder the_url body
    -- |> Task.perform CallFail (CallSucceed command)


update : String -> Http.Response -> Model -> Model
update command response model =
  case command of
    "-x status" ->
      Debug.log ("Right -- " ++ toString response)
      model

    _ ->
      model

