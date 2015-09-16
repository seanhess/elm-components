module Tangle where

import Html exposing (span, Html, div)
import Html.Events exposing (..)
import Html.Attributes exposing (style, draggable)
import Style exposing (Style)
import Signal exposing (Address)
import Events exposing (pageX)
import Json.Decode exposing (value)
import Debug
import VirtualDom

-- I don't KNOW the model!

type alias Model =
  { dragging : Bool
  , start : Float
  , pixelsPerNum : Float
  , lastN : Int
  }

init : Model
init = { dragging = False, start = 0, lastN = 0, pixelsPerNum = 3.0 }

type Action
    = StartDrag Float
    | StopDrag
    | MoveDrag Float

type Event
    = Drag Int
    | None

update : Action -> Model -> (Model, Event)
update action model =
  case action of
    StartDrag pos ->
      ( { model | start <- pos, dragging <- True }, None )

    StopDrag ->
      ( { model | dragging <- False, lastN <- 0, start <- 0}, None )

    MoveDrag pos ->
      if pos == 0 then (model, None) else
      let dx = pos - model.start
          totN = round (dx / model.pixelsPerNum)
          dn = totN - model.lastN
      in
      ( { model | lastN <- totN }, Drag dn )

container : Address Action -> Model -> List Html -> Html
container address model children =
  span
    [ style [ ("position", "relative") ]
    , draggable "false"
    , on "dragstart" pageX (Signal.message address << StartDrag)
    , on "dragend" value (\_ -> Signal.message address StopDrag)
    , on "drag" pageX (Signal.message address << MoveDrag)
    ]
    [ span
        [ style containerStyle ]
        children
    , div [ style coverStyle ] [ ]
    ]

coverStyle : Style
coverStyle =
  [ ("position", "absolute")
  , ("background", "transparent")
  , ("left", "0px")
  , ("top", "0px")
  , ("bottom", "0px")
  , ("right", "0px")
  -- , ("border", "solid 3px blue")
  -- , ("pointer-events", "auto")
  ]

containerStyle : Style
containerStyle =
  [ ("position", "relative")
  , ("color", "#46F")
  , ("cursor", "col-resize")
  , ("border-bottom", "1px dashed #46F")
  -- , ("pointer-events", "auto")
  ]
