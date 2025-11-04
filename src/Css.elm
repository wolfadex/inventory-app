module Css exposing (dropdown, pageCentered, pageMarketing, pageFull)

import Html
import Html.Attributes


dropdown : Html.Attribute msg
dropdown =
    Html.Attributes.class "dropdown"


pageCentered : Html.Attribute msg
pageCentered =
    Html.Attributes.class "pageCentered"


pageMarketing : Html.Attribute msg
pageMarketing =
    Html.Attributes.class "pageMarketing"


pageFull : Html.Attribute msg
pageFull =
    Html.Attributes.class "pageFull"
