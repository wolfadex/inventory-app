module Ui.Button exposing (basic, submit)

import Html exposing (Html)
import Html.Attributes
import Html.Events


basic : { label : String, onClick : msg } -> List (Html.Attribute msg) -> Html msg
basic config attributes =
    Html.button
        ([ Html.Attributes.type_ "button"
         , Html.Events.onClick config.onClick
         ]
            ++ attributes
        )
        [ Html.text config.label ]


submit : { label : String } -> List (Html.Attribute msg) -> Html msg
submit config attributes =
    Html.button
        (Html.Attributes.type_ "submit"
            :: attributes
        )
        [ Html.text config.label ]
