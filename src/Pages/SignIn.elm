module Pages.SignIn exposing
    ( Model, Msg
    , init, update, subscriptions, view
    )

{-|

@docs Model, Msg
@docs init, update, subscriptions, view

-}

import Authentication
import Backend
import Browser
import Effect exposing (Effect)
import Html exposing (Html)
import Html.Attributes
import Html.Events
import Dict
import Submit exposing (Submit)
import Route exposing (Route)
import Icon
import Shared
import Subscription exposing (Subscription)
import Route.Path



-- CONTEXT


type alias Context =
    { shared : Shared.Model
    , route : Route ()
    }



-- MODEL


type alias Model =
    { pathAfterAuth :  Route.Path.Path
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
    | UserAuthenticated (Maybe ())
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
                    Backend.authenticate
                        { email = model.email
                        , password = model.password
                        }
                , onResponse = UserAuthenticated
                }
            )

        UserAuthenticated Nothing ->
            ( { model | submit = Submit.Failed "Error" }
            , Effect.none
            )

        UserAuthenticated (Just ()) ->
            ( model
            , Effect.broadcast (Subscription.RefreshAuthentication (Just model.pathAfterAuth))
            )

        AuthenticationChanged ->
            case shared.currentUser of
                Authentication.Unauthenticated ->
                    ( { model | submit = Submit.Failed "Failed to authenticate" }
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
            [ Html.Attributes.style "display" "flex"
            , Html.Attributes.style "flex-direction" "column"
            , Html.Attributes.style "align-items" "center"
            , Html.Attributes.style "width" "100vw"
            ]
            [ Html.h1 [] [ Html.text "Inventory App" ]
            , Html.form
                [ Html.Events.onSubmit UserSubmittedAuthForm
                , Html.Attributes.style "display" "grid"
                , Html.Attributes.style "grid-template-columns" "5rem 10rem"
                , Html.Attributes.style "gap" "1rem"
                , Html.Attributes.style "border" "1px solid black"
                , Html.Attributes.style "padding" "1rem"
                , Html.Attributes.style "border-radius" "0.5rem"
                ]
                [ Html.label
                    [ Html.Attributes.for "email" ]
                    [ Html.text "Email:" ]
                , Html.input
                    [ Html.Attributes.type_ "email"
                    , Html.Attributes.name "email"
                    , Html.Attributes.value model.email
                    , Html.Events.onInput UserChangedEmail
                    , Html.Attributes.disabled (model.submit == Submit.Submitting)
                    ]
                    []
                , Html.label
                    [ Html.Attributes.for "password" ]
                    [ Html.text "Password:" ]
                , Html.input
                    [ Html.Attributes.type_ "password"
                    , Html.Attributes.name "password"
                    , Html.Attributes.value model.password
                    , Html.Events.onInput UserChangedPassword
                    , Html.Attributes.disabled (model.submit == Submit.Submitting)
                    ]
                    []
                , Html.button
                    [ Html.Attributes.type_ "submit"
                    , Html.Attributes.style "grid-column" "2"
                    , Html.Attributes.disabled (model.submit == Submit.Submitting)
                    ]
                    [ Html.text "Login / Sign Up" ]
                , case model.submit of
                    Submit.Failed error ->
                        Html.span [ Html.Attributes.style "grid-column" "2" ] [ Html.text error ]

                    _ ->
                        Html.text ""
                ]
            ]
        ]
    }


