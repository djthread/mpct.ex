module State exposing (..)

import Api exposing (..)
import Types exposing (..)
import Time

init : Config -> ( Model, Cmd Msg )
init config =
  ( { config  = config,
      state   = ""
    , playing = False
    }
  , Cmd.none
  )


update : Msg -> Model -> ( Model, Cmd Msg )
update action model =
  case action of
    Tick time ->
      ( model, Api.status model.config )

    CallSucceed command data ->
      let
        model = Api.update command data model
      in
        Debug.log "succes."
        ( model, Cmd.none )

    CallFail e ->
      Debug.log ("Error calling " ++ toString action
        ++ ": " ++ toString e)
      ( model, Cmd.none )

    Command command ->
      ( model, Cmd.none )

    Test ->
      ( model, Api.status model.config )


subscriptions : Model -> Sub Msg
subscriptions model =
  let
    time = (model.config.refresh_seconds * Time.second)
  in
    Sub.none
    -- Time.every time Tick
