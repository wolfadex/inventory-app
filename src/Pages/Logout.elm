module Pages.Logout exposing
    ( Model, Msg
    , init, update, subscriptions, view
    )

{-|

@docs Model, Msg
@docs init, update, subscriptions, view

-}

import Acadia.Api
import Acadia.Transaction
import Authentication
import Browser
import Css
import Dict
import Effect exposing (Effect)
import Html exposing (Html)
import Html.Attributes
import Http
import Icon
import Route exposing (Route)
import Route.Path
import Serialize
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
init _ =
    ( {}
    , Effect.acadia
        { transaction =
            Acadia.Transaction.Transaction
                (Serialize.toBytesEncoder Acadia.Api.logoutCodec ())
                (Serialize.toBytesDecoder Acadia.Api.logoutCodec)
        , onResponse = UserLoggedout
        , path = "/auth/logout"
        }
    )



-- UPDATE


type Msg
    = UserLoggedout (Result Http.Error (Result (Serialize.Error ()) ()))


update : Context -> Msg -> Model -> ( Model, Effect Msg )
update { shared } msg model =
    case msg of
        UserLoggedout (Ok (Ok ())) ->
            ( model
            , Effect.batch
                [ Effect.broadcast (Subscription.RefreshAuthentication Nothing)
                , Effect.navigateTo { path = Route.Path.HOME_, query = Dict.empty }
                ]
            )

        UserLoggedout _ ->
            ( model
            , Effect.none
            )



-- SUBSCRIPTIONS


subscriptions : Context -> Model -> Subscription Msg
subscriptions _ _ =
    Subscription.none



-- VIEW


view : Context -> Model -> Browser.Document Msg
view _ _ =
    { title = "Logout"
    , body =
        [ Html.main_ [ Css.pageCentered ]
            [ Html.header
                []
                [ Html.h1 [] [ Html.text "Inventory App" ]
                ]
            , Html.text "Logging out..."
            , Icon.loading 64
            ]
        ]
    }
