module Tangle where

import Html exposing (span, Html, div)
import Html.Events exposing (..)
import Html.Attributes exposing (style, draggable)
import Style exposing (Style)
import Signal exposing (Address)
import Events exposing (pageX)
import Json.Decode exposing (value)
import Debug
import Mouse

-- I don't KNOW the model!

type alias Model =
  { dragging : Bool
  , start : Float
  , pixelsPerNum : Float
  , lastN : Int
  }

type alias MouseProps =
  { isDown : Bool
  , position: (Int, Int)
  }

init : Model
init = { dragging = False, start = 0, lastN = 0, pixelsPerNum = 3.0 }

type Action
    = StartDrag Float
    | StopDrag
    | MoveDrag (Int, Int)

type Event
    = Drag Int
    | None

-- ok, I need some extra information
-- I need to know whether the mouse is up or down
-- I need to know the mouse moving, anywhere
-- hmm... 
-- yeah, I can't do it the normal way here because I need stuff from the outside
update : Action -> Model -> (Model, Event)
update action model =
  case action of
    StartDrag pos ->
      ( { model | start <- pos, dragging <- True }, None )

    StopDrag ->
      ( { model | dragging <- False, lastN <- 0, start <- 0}, None )

    MoveDrag (x, y) ->
      if x == 0 || not model.dragging then (model, None) else
      let pos = toFloat x
          dx = pos - model.start
          totN = round (dx / model.pixelsPerNum)
          dn = totN - model.lastN
      in
      ( { model | lastN <- totN }, Drag dn )

container : Address Action -> Model -> List Html -> Html
container address model children =
  span
    [ style [ ("position", "relative") ]
    , on "mousedown" pageX (Signal.message address << StartDrag)
    -- , onDragEnd value (\_ -> Signal.message address StopDrag)
    -- , onDrag pageX (Signal.message address << MoveDrag)
    ]
    [ span
        [ style containerStyle ]
        children
    -- , div [ style coverStyle ] [ ]
    ]

-- coverStyle : Style
-- coverStyle =
  -- [ ("position", "absolute")
  -- , ("background", "transparent")
  -- , ("left", "0px")
  -- , ("top", "0px")
  -- , ("bottom", "0px")
  -- , ("right", "0px")
  -- -- , ("border", "solid 3px blue")
  -- -- , ("pointer-events", "auto")
  -- ]

containerStyle : Style
containerStyle =
  [ ("position", "relative")
  , ("color", "#46F")
  , ("cursor", "pointer")
  , ("cursor", "move")
  , ("cursor", "col-resize")
  , ("border-bottom", "1px dashed #46F")
  -- , ("pointer-events", "auto")
  ]

paragraphStyle : Style
paragraphStyle = userSelect "none"

userSelect : String -> Style
userSelect value =
  [ ("-moz-user-select", value)
  , ("-webkit-user-select", value)
  , ("-ms-user-select", value)
  , ("user-select", value)
  , ("-o-user-select", value)
  ]


dragStop : Signal Action
dragStop =
  Signal.filter not False Mouse.isDown
    |> Signal.map (always StopDrag)

dragMove : Signal Action
dragMove = Signal.map MoveDrag Mouse.position

