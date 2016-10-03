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
  , host:            String
  , port':           Int
  }

type Msg =
  Tick Time.Time
  | CallFail Http.RawError
  | CallSucceed String Http.Response
  | Command String
  | Test
