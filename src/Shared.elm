module Shared exposing
    ( Model, Msg
    , init, update, subscriptions
    )

{-|

@docs Model, Msg
@docs init, update, subscriptions

-}

import Effect exposing (Effect)
import Interop
import Json.Decode as Json
import Route exposing (Route)
import Subscription exposing (Subscription)



-- MODEL


type alias Model =
    { windowWidth : Float
    }


init : Json.Value -> Route () -> ( Model, Effect Msg )
init json route =
    case Json.decodeValue Interop.decoder json of
        Ok flags ->
            ( { windowWidth = flags.windowWidth }
            , Effect.none
            )

        Err error ->
            ( { windowWidth = 0 }
            , Effect.reportUnexpectedFlags error
            )



-- UPDATE


type Msg
    = WindowResized Int Int


update : Route () -> Msg -> Model -> ( Model, Effect Msg )
update route msg model =
    case msg of
        WindowResized w h ->
            ( { model | windowWidth = Basics.toFloat w }
            , Effect.none
            )



-- SUBSCRIPTIONS


subscriptions : Route () -> Model -> Subscription Msg
subscriptions route model =
    Subscription.onResize WindowResized
