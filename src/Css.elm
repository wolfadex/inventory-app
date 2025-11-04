module Css exposing (dropdown, pageCentered)

import Html
import Html.Attributes


dropdown : Html.Attribute msg
dropdown =
    Html.Attributes.class "dropdown"


pageCentered : Html.Attribute msg
pageCentered =
    Html.Attributes.class "pageCentered"
