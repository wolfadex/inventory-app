module Ui.NumberInput exposing (float)

import Html exposing (Html)
import Html.Attributes
import Html.Events
import Http.Extended
import Submit exposing (Submit)


float :
    { name : String
    , value : String
    , onInput : String -> msg
    , min : Float
    , max : Float
    , label : String
    , submit : Submit output Http.Extended.Error
    }
    -> List (Html.Attribute msg)
    -> Html msg
float config attributes =
    let
        describeByName : String
        describeByName =
            "float-input-" ++ config.name
    in
    Html.label []
        [ Html.text config.label
        , Html.input
            ([ Html.Attributes.type_ "number"
             , Html.Attributes.min (String.fromFloat config.min)
             , Html.Attributes.max (String.fromFloat config.max)
             , Html.Attributes.value config.value
             , Html.Events.onInput config.onInput
             , Html.Attributes.attribute "aria-describedby" describeByName
             , case config.submit of
                Submit.Submitting ->
                    Html.Attributes.disabled True

                Submit.Failed (Http.Extended.Field error) ->
                    if error.name == config.name then
                        Html.Attributes.attribute "aria-invalid" "true"

                    else
                        Html.Attributes.class ""

                _ ->
                    Html.Attributes.class ""
             ]
                ++ attributes
            )
            []
        , case config.submit of
            Submit.Failed (Http.Extended.Field error) ->
                if error.name == config.name then
                    Html.small [ Html.Attributes.id describeByName ]
                        [ Html.text error.message ]

                else
                    Html.text ""

            _ ->
                Html.text ""
        ]
