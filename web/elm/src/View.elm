module View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
-- import Html.Events exposing (..)
import Types exposing (..)

rootView : Model -> Html Msg
rootView model =
  div [ class "container" ]
    [ p [] [ text "SSSap" ]
    ]
