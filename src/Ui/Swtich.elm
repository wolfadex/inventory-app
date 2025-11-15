module Ui.Switch exposing (view)

import Html exposing (Html)
import Html.Attributes
import Html.Events
import Http.Extended
import Submit exposing (Submit)


view :
    { name : String
    , value : Bool
    , onCheck : Bool -> msg
    , label : String
    , submit : Submit a Http.Extended.Error
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
        [ Html.input
            ([ Html.Attributes.type_ "checkbox"
             , Html.Attributes.attribute "role" "switch"
             , Html.Attributes.checked config.value
             , Html.Events.onCheck config.onCheck
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
        , Html.text config.label
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
