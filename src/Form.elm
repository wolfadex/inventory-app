module Form exposing (..)


import Html exposing (Html)
import Html.Attributes
import Html.Events
import Icon
import Submit exposing (Submit)



view { onSubmit, title, fields, submitLabel, submit }=
    Html.form
        [ Html.Events.onSubmit onSubmit
        , Html.Attributes.style "display" "grid"
        , Html.Attributes.style "grid-template-columns" "5rem 10rem"
        , Html.Attributes.style "gap" "1rem"
        , Html.Attributes.style "border" "1px solid black"
        , Html.Attributes.style "padding" "1rem"
        , Html.Attributes.style "border-radius" "0.5rem"
        ]
        (Html.h2
            [ Html.Attributes.style "grid-column" "1 / 3"
            ]
            [ Html.text title ]
            :: List.concatMap
                (\field ->
                    [ Html.label
                        [ Html.Attributes.for field.name ]
                        [ Html.text (field.label ++  ":") ]
                    , Html.input
                        ([ Html.Attributes.name field.name
                        , Html.Attributes.value field.value
                        , Html.Events.onInput field.onInput
                        ] ++ field.attributes)
                        []
                    ]
                )
                fields
            ++ [ Html.div
                    [ Html.Attributes.style "grid-column" "1 / 3"
                    , Html.Attributes.style "justify-content" "flex-end"
                    ]
                    [ Html.button
                        [ Html.Attributes.type_ "submit"
                        ]
                        [ case submit of
                            Submit.Submitting ->
                                Icon.loading

                            _ ->
                                Html.text ""
                        , Html.text submitLabel
                        ]
                    ]
               ]
        )