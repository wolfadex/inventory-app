module Pages.ALL_ exposing
    ( Model, Msg
    , init, update, subscriptions, view
    )

{-|

@docs Model, Msg
@docs init, update, subscriptions, view

-}

import Browser
import Effect exposing (Effect)
import Html exposing (..)
import Html.Attributes exposing (..)
import Route exposing (Route)
import Shared
import Subscription exposing (Subscription)



-- CONTEXT


type alias Context =
    { shared : Shared.Model
    , route : Route Params
    }


type alias Params =
    { all_ : List String
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
    { title = "404"
    , body =
        [ div []
            [ div [] [ img [ width 240, src "/logo.svg" ] [] ]
            , h1 [] [ text "Page not found" ]
            ]
        , p [] [ a [ href "/" ] [ text "Back to the homepage" ] ]
        ]
    }
