module Pages.HOME_ exposing (..)

import Backend
import Html exposing (Html)
import Html.Attributes
import Html.Events
import Browser
import Icon
import Effect exposing (Effect)
import Route exposing (Route)
import Shared
import Subscription exposing (Subscription)
import Response exposing (Response)
import Route.Path


-- CONTEXT


type alias Context =
    { shared : Shared.Model
    , route : Route ()
    }


type alias Model =
    {}

init : Context -> ( Model, Effect Msg )
init { shared, route } =
    ( {}
    , Effect.none
    )


-- SUBSCRIPTIONS


subscriptions : Context -> Model -> Subscription Msg
subscriptions { shared, route } model =
    Subscription.none



-- UPDATE


type Msg
    = NoOp


update : Context -> Msg -> Model -> ( Model, Effect Msg )
update { shared, route } msg model =
    case msg of
        NoOp ->
            ( model
            , Effect.none
            )


view : Context -> Model -> Browser.Document Msg
view { shared, route } model =
    { title = "Homepage"
    , body =
        [ Html.div [ Html.Attributes.class "col align-cx" ]
            [ Icon.logo 240
            , Html.h1 [] [ Html.text "Inventory App" ]
            ]
        , Html.a
            [ Route.Path.href Route.Path.SignIn ]
            [ Html.text "Sign In" ]
        ]
    }