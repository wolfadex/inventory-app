module Shared exposing
    ( Model, Msg
    , init, update, subscriptions
    )

{-|

@docs Model, Msg
@docs init, update, subscriptions

-}

import Acadia.Api
import Acadia.Transaction
import Authentication exposing (Authentication)
import Backend
import Dict
import Effect exposing (Effect)
import Http
import Interop
import Json.Decode as Json
import Route exposing (Route)
import Route.Path
import Serialize
import Subscription exposing (Subscription)



-- MODEL


type alias Model =
    { currentUser : Authentication
    , currentOrganization : Maybe Backend.Organization
    }


init : Json.Value -> Route () -> ( Model, Effect Msg )
init json route =
    ( { currentUser = Authentication.Authenticating
      , currentOrganization = Nothing
      }
    , Effect.acadia
        { transaction =
            Acadia.Transaction.Transaction
                (Serialize.toBytesEncoder Serialize.unit ())
                (Serialize.toBytesDecoder Acadia.Api.getUserSelfCodec)
        , onResponse = GotCurrentUserAndOrg
        , path = "/auth/self"
        }
    )



-- UPDATE


type Msg
    = GotCurrentUserAndOrg (Result Http.Error (Result (Serialize.Error ()) ( Backend.User, Maybe Backend.Organization )))
    | AuthRefreshRequested (Maybe Route.Path.Path)
    | RefreshedAuth (Maybe Route.Path.Path) (Result Http.Error (Result (Serialize.Error ()) ( Backend.User, Maybe Backend.Organization )))


update : Route () -> Msg -> Model -> ( Model, Effect Msg )
update route msg model =
    case msg of
        GotCurrentUserAndOrg (Ok (Ok ( user, maybeOrg ))) ->
            ( { model
                | currentUser = Authentication.Authenticated user
                , currentOrganization = maybeOrg
              }
            , Effect.broadcast Subscription.AuthenticationChanged
            )

        GotCurrentUserAndOrg _ ->
            ( { model | currentUser = Authentication.Unauthenticated }
            , Effect.broadcast Subscription.AuthenticationChanged
            )

        AuthRefreshRequested maybePath ->
            ( { model | currentUser = Authentication.Authenticating }
            , Effect.acadia
                { transaction =
                    Acadia.Transaction.Transaction
                        (Serialize.toBytesEncoder Serialize.unit ())
                        (Serialize.toBytesDecoder Acadia.Api.getUserSelfCodec)
                , onResponse = RefreshedAuth maybePath
                , path = "/auth/self"
                }
            )

        RefreshedAuth maybeRedirect (Ok (Ok ( user, maybeOrg ))) ->
            ( { model
                | currentUser = Authentication.Authenticated user
                , currentOrganization = maybeOrg
              }
            , case maybeRedirect of
                Nothing ->
                    Effect.broadcast Subscription.AuthenticationChanged

                Just path ->
                    Effect.navigateTo { path = path, query = Dict.empty }
            )

        RefreshedAuth _ _ ->
            ( { model | currentUser = Authentication.Unauthenticated }
            , Effect.broadcast Subscription.AuthenticationChanged
            )



-- SUBSCRIPTIONS


subscriptions : Route () -> Model -> Subscription Msg
subscriptions _ _ =
    Subscription.onAuthenticationRefreshRequested AuthRefreshRequested
