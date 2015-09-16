import Html exposing (div, button, text, Html, p, h1, span, pre)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)
import StartApp.Simple as StartApp
import Signal exposing (Address)

import Tangle

type alias Model =
  { tangle : Tangle.Model
  , numCookies : Int
  }

calories : Int -> Int
calories cookies = 50 * cookies

init : Model
init = { tangle = Tangle.init, numCookies = 3 }

view : Address Action -> Model -> Html
view address model =
  div [ style [("margin", "10px")] ]
    [ h1 [] [ text "Tangle Example" ]
    , p []
        [ text "When you eat "
        , Tangle.container
            (Signal.forwardTo address Tangle)
            model.tangle
            [ text ((toString model.numCookies) ++ " cookies") ]
        , text (" you consume " ++ toString (calories model.numCookies) ++ " calories")
        ]
    -- , p [] [ pre [] [ text (toString model) ] ]
    ]

type Action
  = Tangle Tangle.Action

update : Action -> Model -> Model
update action model =
  case action of
    Tangle act ->
      let (tangle, event) = Tangle.update act model.tangle
          num = case event of
            Tangle.Drag n -> model.numCookies + n
            _ -> model.numCookies
      in { model | tangle <- tangle, numCookies <- num }

-----------------------------------------------------------------
main =
  StartApp.start { model = init, view = view, update = update }

