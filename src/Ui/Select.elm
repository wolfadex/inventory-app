module Ui.Select exposing (view)

import Html exposing (Html)
import Html.Attributes
import Html.Events
import Http.Extended
import Submit exposing (Submit)


view :
    { name : String
    , value : Maybe a
    , toStringValue : a -> String
    , options : List { label : String, value : a }
    , onSelect : Maybe a -> msg
    , label : String
    , submit : Submit b Http.Extended.Error
    }
    -> List (Html.Attribute msg)
    -> Html msg
view config attributes =
    let
        describeByName : String
        describeByName =
            "switch-input-" ++ config.name
    in
    Html.label []
        [ Html.text config.label
        , Html.select
            ([ Html.Attributes.attribute "role" "switch"
             , Html.Attributes.value
                (case Debug.log "val" config.value of
                    Nothing ->
                        ""

                    Just value ->
                        config.toStringValue value
                )
             , Html.Events.onInput (optionFind config.toStringValue config.options >> config.onSelect)
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
            (List.map
                (\option ->
                    Html.option
                        [ Html.Attributes.value (config.toStringValue option.value)
                        ]
                        [ Html.text option.label ]
                )
                config.options
            )
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


optionFind : (a -> String) -> List { label : String, value : a } -> String -> Maybe a
optionFind toStr options valueStr =
    if valueStr == "" then
        Nothing

    else
        case options of
            [] ->
                Nothing

            next :: rest ->
                if toStr next.value == valueStr then
                    Just next.value

                else
                    optionFind toStr rest valueStr
