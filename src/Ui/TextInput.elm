module Ui.TextInput exposing (..)

import Html exposing (Html)
import Html.Attributes
import Html.Events


basic : { value : String, onInput : String -> msg, label : String } -> List (Html.Attribute msg) -> Html msg
basic config attributes =
    Html.label []
        [ Html.text config.label
        , Html.input
            ([ Html.Attributes.value config.value
             , Html.Events.onInput config.onInput
             ]
                ++ attributes
            )
            []
        ]


email : { value : String, onInput : String -> msg, label : String } -> List (Html.Attribute msg) -> Html msg
email config attributes =
    Html.label []
        [ Html.text config.label
        , Html.input
            ([ Html.Attributes.value config.value
             , Html.Events.onInput config.onInput
             , Html.Attributes.type_ "email"
             ]
                ++ attributes
            )
            []
        ]


password : { value : String, onInput : String -> msg, label : String } -> List (Html.Attribute msg) -> Html msg
password config attributes =
    Html.label []
        [ Html.text config.label
        , Html.input
            ([ Html.Attributes.value config.value
             , Html.Events.onInput config.onInput
             , Html.Attributes.type_ "password"
             ]
                ++ attributes
            )
            []
        ]
