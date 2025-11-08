module Shared exposing
    ( Model, Msg
    , init, update, subscriptions
    )

{-|

@docs Model, Msg
@docs init, update, subscriptions

-}

import Authentication exposing (Authentication)
import Backend
import Dict
import Effect exposing (Effect)
import Endpoints.ApiAuthSelf
import Http.Extended
import Json.Decode as Json
import Route exposing (Route)
import Route.Path
import Subscription exposing (Subscription)



-- MODEL


type alias Model =
    { currentUser : Authentication
    , currentOrganization : Maybe Backend.Organization
    }


init : Json.Value -> Route () -> ( Model, Effect Msg )
init _ _ =
    ( { currentUser = Authentication.Authenticating
      , currentOrganization = Nothing
      }
    , Endpoints.ApiAuthSelf.post GotCurrentUserAndOrg
    )



-- UPDATE


type Msg
    = GotCurrentUserAndOrg (Result Http.Extended.Error ( Backend.User, Maybe Backend.Organization ))
    | AuthRefreshRequested (Maybe String)
    | RefreshedAuth (Maybe String) (Result Http.Extended.Error ( Backend.User, Maybe Backend.Organization ))


update : Route () -> Msg -> Model -> ( Model, Effect Msg )
update _ msg model =
    case msg of
        GotCurrentUserAndOrg (Ok ( user, maybeOrg )) ->
            ( { model
                | currentUser = Authentication.Authenticated user
                , currentOrganization = maybeOrg
              }
            , Effect.broadcast Subscription.AuthenticationChanged
            )

        GotCurrentUserAndOrg (Err _) ->
            ( { model | currentUser = Authentication.Unauthenticated }
            , Effect.broadcast Subscription.AuthenticationChanged
            )

        AuthRefreshRequested maybePath ->
            ( { model | currentUser = Authentication.Authenticating }
            , Endpoints.ApiAuthSelf.post (RefreshedAuth maybePath)
            )

        RefreshedAuth maybeRedirect (Ok ( user, maybeOrg )) ->
            ( { model
                | currentUser = Authentication.Authenticated user
                , currentOrganization = maybeOrg
              }
            , case maybeRedirect of
                Nothing ->
                    Effect.broadcast Subscription.AuthenticationChanged

                Just path ->
                    Effect.pushUrl path
            )

        RefreshedAuth _ (Err _) ->
            ( { model | currentUser = Authentication.Unauthenticated }
            , Effect.broadcast Subscription.AuthenticationChanged
            )



-- SUBSCRIPTIONS


subscriptions : Route () -> Model -> Subscription Msg
subscriptions _ _ =
    Subscription.onAuthenticationRefreshRequested AuthRefreshRequested
