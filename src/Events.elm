module Events where

import Json.Decode as Json exposing (..)

type alias Position =
  { x : Float
  , y : Float
  }

clientPosition : Json.Decoder Position
clientPosition =
  Json.object2 Position
    clientX
    clientY

clientX : Json.Decoder Float
clientX =
  ("clientX" := Json.float)

clientY : Json.Decoder Float
clientY =
  ("clientY" := Json.float)

pageX : Json.Decoder Float
pageX =
  ("pageX" := Json.float)

