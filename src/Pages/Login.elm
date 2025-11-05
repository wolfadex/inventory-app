module Pages.Login exposing
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
    , submit : Submit String Acadia.Api.Error
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
    | UserLoggedIn (Result Acadia.Api.Error (Result (Serialize.Error ()) ()))
    | AuthenticationChanged


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

        UserLoggedIn (Ok (Ok ())) ->
            ( model
            , Effect.broadcast (Subscription.RefreshAuthentication (Just model.pathAfterAuth))
            )

        UserLoggedIn (Ok (Err _)) ->
            ( { model | submit = Submit.Failed (Acadia.Api.Generic "Error") }
            , Effect.none
            )

        UserLoggedIn (Err err) ->
            ( { model | submit = Submit.Failed err }
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
                                Submit.Failed (Acadia.Api.Generic "Failed to login")
                      }
                    , Effect.none
                    )

                Authentication.Authenticating ->
                    ( model, Effect.none )

                Authentication.Authenticated _ ->
                    ( model
                    , case shared.currentOrganization of
                        Just _ ->
                            Effect.navigateTo { path = model.pathAfterAuth, query = Dict.empty }

                        Nothing ->
                            Effect.navigateTo { path = Route.Path.OrganizationInit, query = Dict.empty }
                    )



-- SUBSCRIPTIONS


subscriptions : Context -> Model -> Subscription Msg
subscriptions _ _ =
    Subscription.onAuthenticationChange AuthenticationChanged



-- VIEW


view : Context -> Model -> Browser.Document Msg
view _ model =
    { title = "Login"
    , body =
        [ Html.main_
            [ Css.pageCentered
            ]
            [ Html.header
                []
                [ Icon.logo 64
                , Html.strong [ Html.Attributes.style "font-size" "3rem" ] [ Html.text "Inventory App" ]
                ]
            , Html.article []
                [ Ui.Form.view
                    { name = "login"
                    , title = "Login"
                    , onSubmit = UserSubmittedAuthForm
                    , submit = model.submit
                    , submitLabel = "Login"
                    , additionalButtons = []
                    , fields =
                        [ Ui.TextInput.email
                            { name = "email"
                            , label = "Email"
                            , value = model.email
                            , onInput = UserChangedEmail
                            , submit = model.submit
                            }
                            []
                        , Ui.TextInput.password
                            { name = "password"
                            , label = "Password"
                            , value = model.password
                            , onInput = UserChangedPassword
                            , submit = model.submit
                            }
                            []
                        ]
                    }
                ]
            , Html.footer []
                [ Html.a [ Route.Path.href Route.Path.SignUp ]
                    [ Html.text "Sign up" ]
                ]
            ]
        ]
    }
