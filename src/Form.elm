module Form exposing (..)

import Html exposing (Html)
import Html.Attributes
import Html.Events
import Icon
import Submit exposing (Submit)


view { onSubmit, title, fields, submitLabel, submit, additionalButtons } =
    Html.form
        [ Html.Events.onSubmit onSubmit
        ]
        (Html.h2
            []
            [ Html.text title ]
            :: List.concatMap
                (\field ->
                    [ Html.label
                        [ Html.Attributes.for field.name ]
                        [ Html.text (field.label ++ ":") ]
                    , Html.input
                        ([ Html.Attributes.name field.name
                         , Html.Attributes.value field.value
                         , Html.Events.onInput field.onInput
                         ]
                            ++ field.attributes
                        )
                        []
                    ]
                )
                fields
            ++ [ Html.div
                    [ Html.Attributes.class "grid" ]
                    (List.map
                        (\btn ->
                            Html.button
                                [ Html.Attributes.type_ "button"
                                , Html.Events.onClick btn.onClick
                                , Html.Attributes.class "outline"
                                ]
                                [ case submit of
                                    Submit.Submitting ->
                                        Icon.loading

                                    _ ->
                                        Html.text ""
                                , Html.text btn.label
                                ]
                        )
                        additionalButtons
                        ++ [ Html.button
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
                    )
               ]
        )
