module Types exposing (..)

import Time
import Http

type alias Model =
  { config:  Config
  , state:   String
  , playing: Bool
  }

type alias Config =
  { refresh_seconds: Float
  , http_host:       String
  , http_port:       Int
  }

type Msg =
  Tick Time.Time
  | CallSucceed String String
  | CallFail Http.Error
  | TogglePlaying
