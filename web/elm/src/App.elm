module App exposing (..)

import Html.App
import State
import View
import Types exposing (..)


config : Config
config =
  { refresh_seconds = 3
  , host            = "localhost"
  , port'           = 6601
  }


main : Program Never
main =
  Html.App.program
    { init          = State.init config
    , update        = State.update
    , subscriptions = State.subscriptions
    , view          = View.rootView
    }
