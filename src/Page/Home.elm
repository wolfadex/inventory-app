module Page.Home exposing (..)

import Backend
import Html exposing (Html)
import Html.Attributes
import Html.Events


type alias Model =
    {}


init : () -> ( Model, Cmd Msg )
init () =
    ( {}
    , Cmd.none
    )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


type Msg
    = NoOp


update :
    { msg : Msg
    , model : Model
    , toMsg : Msg -> msg
    , toModel : Model -> model
    }
    -> ( model, Cmd msg )
update ({ model } as config) =
    case config.msg of
        NoOp ->
            ( config.toModel model
            , Cmd.none
            )


view : Backend.User -> Model -> Html Msg
view user model =
    Html.div []
        [ Html.h1 [] [ Html.text "Inventory App" ]

        -- , Html.text (user.primaryEmail ++ " logged in")
        ]
