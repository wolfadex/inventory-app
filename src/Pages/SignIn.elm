module Pages.SignIn exposing
    ( Model, Msg
    , init, update, subscriptions, view
    )

{-|

@docs Model, Msg
@docs init, update, subscriptions, view

-}

import Browser
import Effect exposing (Effect)
import Html exposing (Html)
import Html.Attributes
import Route exposing (Route)
import Components.Icon
import Shared
import Subscription exposing (Subscription)



-- CONTEXT


type alias Context =
    { shared : Shared.Model
    , route : Route ()
    }



-- MODEL


type alias Model =
    {}


init : Context -> ( Model, Effect Msg )
init { shared, route } =
    ( {}
    , Effect.none
    )



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



-- SUBSCRIPTIONS


subscriptions : Context -> Model -> Subscription Msg
subscriptions { shared, route } model =
    Subscription.none



-- VIEW


view : Context -> Model -> Browser.Document Msg
view { shared, route } model =
    { title = "Sign in"
    , body =
        [ Html.div []
            [ Html.div [Html.Attributes.class "col align-cx"]
            [ Components.Icon.logo 240 ]
            , Html.h1 [] [ Html.text "Welcome to Elm Land!" ]
            ]
        , Html.p [] [ Html.text "Let's get you signed in..." ]
        ]
    }
