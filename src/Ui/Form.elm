module Ui.Form exposing (..)

import Html exposing (Html)
import Html.Attributes
import Html.Events
import Icon
import Submit exposing (Submit)
import Ui.Button


view :
    { onSubmit : msg
    , title : String
    , fields : List (Html msg)
    , submitLabel : String
    , submit : Submit a e
    , additionalButtons : List { onClick : msg, label : String }
    }
    -> Html msg
view { onSubmit, title, fields, submitLabel, submit, additionalButtons } =
    Html.form
        [ Html.Events.onSubmit onSubmit
        ]
        (Html.h2
            []
            [ Html.text title ]
            :: fields
            ++ [ Html.div
                    [ Html.Attributes.class "grid" ]
                    (List.map
                        (\btn ->
                            Ui.Button.view
                                { label = btn.label }
                                [ Html.Events.onClick btn.onClick
                                , Html.Attributes.attribute "appearance" "filled"
                                , Html.Attributes.attribute "variant" "neutral"
                                , Html.Attributes.class "outline"
                                , case submit of
                                    Submit.Submitting ->
                                        Html.Attributes.attribute "aria-busy" "true"

                                    _ ->
                                        Html.Attributes.class ""
                                ]
                        )
                        additionalButtons
                        ++ [ Ui.Button.view
                                { label = submitLabel }
                                [ Html.Attributes.type_ "submit"
                                , Html.Attributes.attribute "appearance" "accent"
                                , Html.Attributes.attribute "variant" "brand"
                                , case submit of
                                    Submit.Submitting ->
                                        Html.Attributes.attribute "aria-busy" "true"

                                    _ ->
                                        Html.Attributes.class ""
                                ]
                           ]
                    )
               ]
        )
