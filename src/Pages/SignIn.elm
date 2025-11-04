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
import Ui.Form
import Ui.TextInput



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
                |> Debug.log "return to"
                |> Maybe.map Route.Path.fromString
                |> Debug.log "from str"
                |> Maybe.withDefault Route.Path.Dashboard
                |> Debug.log "final"
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
    | UserLoggedIn (Result Http.Error (Result (Serialize.Error ()) ()))
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
                        (Serialize.toBytesDecoder Acadia.Api.loginCodec)
                , onResponse = UserLoggedIn
                , path = "/auth/login"
                }
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
                        (Serialize.toBytesDecoder Acadia.Api.loginCodec)
                , onResponse = UserLoggedIn
                , path = "/auth/signup"
                }
            )

        UserLoggedIn (Ok (Ok ())) ->
            ( model
            , Effect.broadcast (Subscription.RefreshAuthentication (Just model.pathAfterAuth))
            )

        UserLoggedIn _ ->
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
                                Submit.Failed "Failed to login"
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
        [ Html.header
            []
            [ Html.h1 [] [ Html.text "Inventory App" ]
            ]
        , Html.main_ []
            [ Html.article []
                [ Ui.Form.view
                    { title = "Login"
                    , onSubmit = UserSubmittedAuthForm
                    , submit = model.submit
                    , submitLabel = "Login"
                    , additionalButtons =
                        [ { onClick = UserClickedSignUp
                          , label = "Sign up"
                          }
                        ]
                    , fields =
                        [ Ui.TextInput.email
                            { label = "Email"
                            , value = model.email
                            , onInput = UserChangedEmail
                            }
                            [ Html.Attributes.disabled (model.submit == Submit.Submitting)
                            , Html.Attributes.type_ "email"
                            ]
                        , Ui.TextInput.password
                            { label = "Password"
                            , value = model.password
                            , onInput = UserChangedPassword
                            }
                            [ Html.Attributes.disabled (model.submit == Submit.Submitting)
                            , Html.Attributes.type_ "password"
                            ]
                        ]
                    }
                ]
            ]
        ]
    }
