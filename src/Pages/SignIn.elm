module Pages.SignIn exposing
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
import Backend
import Browser
import Bytes.Encode
import Dict
import Effect exposing (Effect)
import Form
import Html exposing (Html)
import Html.Attributes
import Html.Events
import Http
import Icon
import Route exposing (Route)
import Route.Path
import Serialize
import Shared
import Submit exposing (Submit)
import Subscription exposing (Subscription)



-- CONTEXT


type alias Context =
    { shared : Shared.Model
    , route : Route ()
    }



-- MODEL


type alias Model =
    { pathAfterAuth : Route.Path.Path
    , email : String
    , password : String
    , submit : Submit () String
    }


init : Context -> ( Model, Effect Msg )
init { shared, route } =
    let
        pathAfterAuth =
            route.query
                |> Dict.get "returnto"
                |> Maybe.map Route.Path.fromString
                |> Maybe.withDefault Route.Path.Dashboard
    in
    ( { pathAfterAuth = pathAfterAuth
      , email = ""
      , password = ""
      , submit = Submit.Fresh
      }
    , case shared.currentUser of
        Authentication.Unauthenticated ->
            Effect.none

        Authentication.Authenticating ->
            Effect.none

        Authentication.Authenticated user ->
            case shared.currentOrganization of
                Just _ ->
                    Effect.navigateTo { path = pathAfterAuth, query = Dict.empty }

                Nothing ->
                    Effect.navigateTo { path = Route.Path.OrganizationInit, query = Dict.empty }
    )



-- UPDATE


type Msg
    = UserChangedEmail String
    | UserChangedPassword String
    | UserSubmittedAuthForm
    | UserAuthenticated (Result Http.Error (Result (Serialize.Error ()) ()))
    | Carl (Result Http.Error ())
    | AuthenticationChanged
    | UserClickedSignUp


update : Context -> Msg -> Model -> ( Model, Effect Msg )
update { shared, route } msg model =
    case msg of
        UserChangedEmail email ->
            ( { model | email = email }
            , Effect.none
            )

        UserChangedPassword password ->
            ( { model | password = password }
            , Effect.none
            )

        UserSubmittedAuthForm ->
            ( { model | submit = Submit.Submitting }
            , Effect.acadia
                { transaction =
                    Acadia.Transaction.Transaction
                        (Serialize.toBytesEncoder Acadia.Api.authInfoCodec
                            { email = model.email
                            , password = model.password
                            }
                        )
                        (Serialize.toBytesDecoder Acadia.Api.authenticateCodec)
                , onResponse = UserAuthenticated
                , path = "/auth/authenticate"
                }
              -- , let
              --     (Acadia.Transaction.Transaction enc dec) =
              --         Backend.authenticate
              --             { email = model.email
              --             , password = model.password
              --             }
              --   in
              --   Http.post
              --     { url = "/_endpoints"
              --     , body = Http.bytesBody "application/octet-stream" (Bytes.Encode.encode enc)
              --     , expect =
              --         Http.expectBytes Carl dec
              --     }
              --     |> Effect.command
            )

        Carl _ ->
            ( model, Effect.none )

        UserClickedSignUp ->
            ( { model | submit = Submit.Submitting }
            , Effect.acadia
                { transaction =
                    Acadia.Transaction.Transaction
                        (Serialize.toBytesEncoder Acadia.Api.authInfoCodec
                            { email = model.email
                            , password = model.password
                            }
                        )
                        (Serialize.toBytesDecoder Acadia.Api.authenticateCodec)
                , onResponse = UserAuthenticated
                , path = "/auth/signup"
                }
            )

        UserAuthenticated (Ok (Ok ())) ->
            ( model
            , Effect.broadcast (Subscription.RefreshAuthentication (Just model.pathAfterAuth))
            )

        UserAuthenticated _ ->
            ( { model | submit = Submit.Failed "Error" }
            , Effect.none
            )

        AuthenticationChanged ->
            case shared.currentUser of
                Authentication.Unauthenticated ->
                    ( { model
                        | submit =
                            if String.isEmpty model.email && String.isEmpty model.password then
                                Submit.Fresh

                            else
                                Submit.Failed "Failed to authenticate"
                      }
                    , Effect.none
                    )

                Authentication.Authenticating ->
                    ( model, Effect.none )

                Authentication.Authenticated user ->
                    ( model
                    , case shared.currentOrganization of
                        Just _ ->
                            Effect.navigateTo { path = model.pathAfterAuth, query = Dict.empty }

                        Nothing ->
                            Effect.navigateTo { path = Route.Path.OrganizationInit, query = Dict.empty }
                    )



-- SUBSCRIPTIONS


subscriptions : Context -> Model -> Subscription Msg
subscriptions { shared, route } model =
    Subscription.onAuthenticationChange AuthenticationChanged



-- VIEW


view : Context -> Model -> Browser.Document Msg
view { shared, route } model =
    { title = "Sign in"
    , body =
        [ Html.div
            []
            [ Html.h1 [] [ Html.text "Inventory App" ]
            , Form.view
                { title = "Setup organization"
                , onSubmit = UserSubmittedAuthForm
                , submit = model.submit
                , submitLabel = "Login"
                , additionalButtons =
                    [ { onClick = UserClickedSignUp
                      , label = "Sign up"
                      }
                    ]
                , fields =
                    [ { name = "email"
                      , label = "Email"
                      , value = model.email
                      , onInput = UserChangedEmail
                      , attributes =
                            [ Html.Attributes.disabled (model.submit == Submit.Submitting)
                            , Html.Attributes.type_ "email"
                            ]
                      }
                    , { name = "password"
                      , label = "Password"
                      , value = model.password
                      , onInput = UserChangedPassword
                      , attributes =
                            [ Html.Attributes.disabled (model.submit == Submit.Submitting)
                            , Html.Attributes.type_ "password"
                            ]
                      }
                    ]
                }
            ]
        ]
    }
