module Ui.TextInput exposing
    ( basic
    , email
    , password
    )

import Acadia.Api
import Html exposing (Html)
import Html.Attributes
import Html.Events
import Submit exposing (Submit)


basic :
    { name : String
    , value : String
    , onInput : String -> msg
    , label : String
    , submit : Submit String Acadia.Api.Error
    }
    -> List (Html.Attribute msg)
    -> Html msg
basic config attributes =
    common config attributes


email :
    { name : String
    , value : String
    , onInput : String -> msg
    , label : String
    , submit : Submit String Acadia.Api.Error
    }
    -> List (Html.Attribute msg)
    -> Html msg
email config attributes =
    common config (Html.Attributes.type_ "email" :: attributes)


password :
    { name : String
    , value : String
    , onInput : String -> msg
    , label : String
    , submit : Submit String Acadia.Api.Error
    }
    -> List (Html.Attribute msg)
    -> Html msg
password config attributes =
    common config (Html.Attributes.type_ "password" :: attributes)


common :
    { name : String
    , value : String
    , onInput : String -> msg
    , label : String
    , submit : Submit String Acadia.Api.Error
    }
    -> List (Html.Attribute msg)
    -> Html msg
common config attributes =
    let
        describeByName =
            "text-input-" ++ config.name
    in
    Html.label []
        [ Html.text config.label
        , Html.input
            ([ Html.Attributes.value config.value
             , Html.Events.onInput config.onInput
             , Html.Attributes.attribute "aria-describedby" describeByName
             , case config.submit of
                Submit.Submitting ->
                    Html.Attributes.disabled True

                Submit.Failed (Acadia.Api.Field error) ->
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
            Submit.Failed (Acadia.Api.Field error) ->
                if error.name == config.name then
                    Html.small [ Html.Attributes.id describeByName ]
                        [ Html.text error.message ]

                else
                    Html.text ""

            _ ->
                Html.text ""
        ]
