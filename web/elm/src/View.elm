module View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Types exposing (..)

rootView : Model -> Html Msg
rootView model =
  div [ class "container" ]
    [ p [] [ text "SSSap" ]
    , p []
      [ button [ onClick Test ] [ text "Update Status" ]
      ]
    ]
