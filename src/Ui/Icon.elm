module Ui.Icon exposing
    ( Attribute
    , envelope
    , lock
    , slot
    , variant
    )

import Html exposing (Html)
import Html.Attributes


type Attribute msg
    = Attribute (Html.Attribute msg)



-- ICONS


envelope : List (Attribute msg) -> Html msg
envelope attributes =
    Html.node "wa-icon"
        (List.map toHtmlAttribute attributes ++ [ Html.Attributes.name "envelope" ])
        []


lock : List (Attribute msg) -> Html msg
lock attributes =
    Html.node "wa-icon"
        (List.map toHtmlAttribute attributes ++ [ Html.Attributes.name "lock" ])
        []



-- ATTRIBUTES


slot : String -> Attribute msg
slot name =
    Attribute (Html.Attributes.attribute "slot" name)


variant : String -> Attribute msg
variant name =
    Attribute (Html.Attributes.attribute "variant" name)



-- INTERNAL


toHtmlAttribute : Attribute msg -> Html.Attribute msg
toHtmlAttribute (Attribute attr) =
    attr
