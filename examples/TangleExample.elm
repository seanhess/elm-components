import Html exposing (div, button, text, Html, p, h1, span, pre)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)
import StartApp as StartApp
import Signal exposing (Address)
import Effects exposing (Effects)
import Mouse
import Focus exposing (create, get, set, update, Focus)

import Tangle

type alias Model =
  { first : Tangle.Model
  , second : Tangle.Model
  , numCookies : Int
  , numEggs : Int
  }

first = create .first (\f r -> { r | first <- f r.first })
second = create .second (\f r -> { r | second <- f r.second })
numCookies = create .numCookies (\f r -> { r | numCookies <- f r.numCookies })
numEggs    = create .numEggs    (\f r -> { r | numEggs    <- f r.numEggs    })

calories : Int -> Int -> Int
calories cals num = num * cals

caloriesCookies = calories 50
caloriesEggs = calories 66

init : Model
init = { first = Tangle.init, second = Tangle.init, numCookies = 3, numEggs = 2}

view : Address Action -> Model -> Html
view address model =
  let calsCookies = caloriesCookies model.numCookies
      calsEggs = caloriesEggs model.numEggs
  in
  div [ style [("margin", "10px")] ]
    [ h1 [] [ text "Tangle Example" ]
    , p [ style Tangle.paragraphStyle ]
        [ text "When you eat "

        , Tangle.container
            (Signal.forwardTo address First)
            model.first
            [ text ((toString model.numCookies) ++ " cookies") ]

        , text " and "

        , Tangle.container
            (Signal.forwardTo address Second)
            model.second
            [ text ((toString model.numEggs) ++ " eggs") ]

        , text (" you consume " ++ toString (calsCookies + calsEggs) ++ " calories")
        ]
    -- , p [] [ pre [] [ text (toString model) ] ]
    ]

type Action
  = First Tangle.Action
  | Second Tangle.Action
  | All Tangle.Action

updateApp : Action -> Model -> (Model, Effects Action)
updateApp action model =
  case action of
    First act ->
      ( model |> updateTangle first numCookies act
      , Effects.none )

    Second act ->
      ( model |> updateTangle second numEggs act
      , Effects.none )

    All act ->
      ( model
          |> updateTangle first numCookies act
          |> updateTangle second numEggs act
      , Effects.none )

updateTangle : Focus Model Tangle.Model -> Focus Model Int -> Tangle.Action -> Model -> Model
updateTangle tangle value act model =
  let (t, ev) = Tangle.update act (get tangle model)
      val = case ev of
        Tangle.Drag n -> get value model + n
        _ -> get value model
  in
  model
    |> set value val
    |> set tangle t

-----------------------------------------------------------------

app =
  StartApp.start
    { init = (init, Effects.none)
    , inputs = [
        Signal.map All Tangle.dragStop,
        Signal.map All Tangle.dragMove
      ]
    , view = view
    , update = updateApp
    }

main = app.html

