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
import Dict
import Json.Decode as Json
import Route exposing (Route)
import Effect
import Subscription exposing (Subscription)
import Backend
import Authentication exposing (Authentication)
import Route.Path



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
        { transaction = Backend.getUserSelf
        , onResponse = GotCurrentUserAndOrg
        }
    )



-- UPDATE


type Msg
    = GotCurrentUserAndOrg (Maybe ( Backend.User, Maybe Backend.Organization ))
    | AuthRefreshRequested (Maybe Route.Path.Path)
    | RefreshedAuth (Maybe Route.Path.Path) (Maybe ( Backend.User, Maybe Backend.Organization ))


update : Route () -> Msg -> Model -> ( Model, Effect Msg )
update route msg model =
    case msg of
        GotCurrentUserAndOrg Nothing ->
            ( { model | currentUser = Authentication.Unauthenticated }
            , Effect.broadcast Subscription.AuthenticationChanged
            )

        GotCurrentUserAndOrg (Just ( user, maybeOrg )) ->
            ( { model
                | currentUser = Authentication.Authenticated user
                , currentOrganization = maybeOrg
              }
            , Effect.broadcast Subscription.AuthenticationChanged
            )

        AuthRefreshRequested maybePath ->
            ( { model | currentUser = Authentication.Authenticating }
            , Effect.acadia
                { transaction = Backend.getUserSelf
                , onResponse = GotCurrentUserAndOrg
                }
            )

        RefreshedAuth _ Nothing ->
            ( { model | currentUser = Authentication.Unauthenticated }
            , Effect.broadcast Subscription.AuthenticationChanged
            )

        RefreshedAuth maybeRedirect (Just ( user, maybeOrg )) ->
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



-- SUBSCRIPTIONS


subscriptions : Route () -> Model -> Subscription Msg
subscriptions route model =
    Subscription.onAuthenticationRefreshRequested AuthRefreshRequested
