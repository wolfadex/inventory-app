module Ui.Form exposing (view)

import Acadia.Api
import Html exposing (Html)
import Html.Attributes
import Html.Events
import Submit exposing (Submit)
import Ui.Button


view :
    { name : String
    , onSubmit : msg
    , title : String
    , fields : List (Html msg)
    , submitLabel : String
    , submit : Submit a Acadia.Api.Error
    , additionalButtons : List { onClick : msg, label : String }
    }
    -> Html msg
view ({ onSubmit, title, fields, submitLabel, submit, additionalButtons } as config) =
    let
        describeByName : String
        describeByName =
            "form-description-" ++ config.name
    in
    Html.form
        [ Html.Events.onSubmit onSubmit
        , Html.Attributes.attribute "aria-describedby" describeByName
        , case submit of
            Submit.Submitting ->
                Html.Attributes.disabled True

            Submit.Failed (Acadia.Api.Generic _) ->
                Html.Attributes.attribute "aria-invalid" "true"

            _ ->
                Html.Attributes.class ""
        ]
        (Html.h2
            []
            [ Html.text title ]
            :: fields
            ++ [ case submit of
                    Submit.Failed (Acadia.Api.Generic errorMessage) ->
                        Html.small [ Html.Attributes.id describeByName ]
                            [ Html.text errorMessage ]

                    _ ->
                        Html.text ""
               , Html.div
                    [ Html.Attributes.class "grid" ]
                    (List.map
                        (\btn ->
                            Ui.Button.basic
                                { label = btn.label, onClick = btn.onClick }
                                [ Html.Attributes.attribute "appearance" "filled"
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
                        ++ [ Ui.Button.submit
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
