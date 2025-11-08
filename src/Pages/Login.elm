module Pages.Login exposing
    ( Model, Msg
    , init, update, subscriptions, view
    , Context
    )

{-|

@docs Model, Msg
@docs init, update, subscriptions, view

-}

import Authentication
import Browser
import Css
import Dict
import Effect exposing (Effect)
import Endpoints.ApiAuthLogin
import Html
import Html.Attributes
import Http.Extended
import Icon
import Route exposing (Route)
import Route.Path
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
    { pathAfterAuth : String
    , email : String
    , password : String
    , submit : Submit String Http.Extended.Error
    }


init : Context -> ( Model, Effect Msg )
init { shared, route } =
    let
        pathAfterAuth : String
        pathAfterAuth =
            route.query
                |> Dict.get "returnto"
                |> Maybe.withDefault (Route.Path.toString Route.Path.Dashboard)
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

        Authentication.Authenticated _ ->
            case shared.currentOrganization of
                Just _ ->
                    Effect.pushUrl pathAfterAuth

                Nothing ->
                    Effect.routeTo { path = Route.Path.OrganizationInit, query = Dict.empty }
    )



-- UPDATE


type Msg
    = UserChangedEmail String
    | UserChangedPassword String
    | UserSubmittedAuthForm
    | UserLoggedIn (Result Http.Extended.Error ())
    | AuthenticationChanged


update : Context -> Msg -> Model -> ( Model, Effect Msg )
update { shared } msg model =
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
            , Endpoints.ApiAuthLogin.post UserLoggedIn
                { email = model.email
                , password = model.password
                }
            )

        UserLoggedIn (Ok ()) ->
            ( model
            , Effect.broadcast (Subscription.RefreshAuthentication (Just model.pathAfterAuth))
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
                                Submit.Failed (Http.Extended.Generic "Failed to login")
                      }
                    , Effect.none
                    )

                Authentication.Authenticating ->
                    ( model, Effect.none )

                Authentication.Authenticated _ ->
                    ( model
                    , case shared.currentOrganization of
                        Just _ ->
                            Effect.pushUrl model.pathAfterAuth

                        Nothing ->
                            Effect.routeTo { path = Route.Path.OrganizationInit, query = Dict.empty }
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
