module Ui.Button exposing (..)

import Html exposing (Html)
import Html.Attributes
import Html.Events


view : { label : String } -> List (Html.Attribute msg) -> Html msg
view config attributes =
    Html.button
        ([ Html.Attributes.type_ "button"
         ]
            ++ attributes
        )
        [ Html.text config.label ]
