module Pages.OrganizationInit exposing
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
    { name : String
    , submit : Submit () String
    }


init : Context -> ( Model, Effect Msg )
init { shared, route } =
    ( { name = ""
      , submit = Submit.Fresh
      }
    , case shared.currentUser of
        Authentication.Unauthenticated ->
            Effect.navigateTo { path = Route.Path.SignIn, query = Dict.empty }

        Authentication.Authenticating ->
            Effect.none

        Authentication.Authenticated user ->
            Effect.none
    )



-- UPDATE


type Msg
    = UserChangedName String
    | UserSubmittedForm
    | AuthenticationChanged
    | OrganizationCreated (Result Http.Error (Result (Serialize.Error ()) Backend.Organization))


update : Context -> Msg -> Model -> ( Model, Effect Msg )
update { shared, route } msg model =
    case msg of
        AuthenticationChanged ->
            ( model
            , case shared.currentUser of
                Authentication.Authenticated _ ->
                    Effect.none

                Authentication.Authenticating ->
                    Effect.none

                Authentication.Unauthenticated ->
                    Effect.navigateTo { path = Route.Path.SignIn, query = Dict.empty }
            )

        UserChangedName name ->
            ( { model | name = name }
            , Effect.none
            )

        UserSubmittedForm ->
            ( model
            , Effect.acadia
                { transaction =
                    Acadia.Transaction.Transaction
                        (Serialize.toBytesEncoder Acadia.Api.createOrganizationCodec
                            { name = model.name
                            }
                        )
                        (Serialize.toBytesDecoder Acadia.Api.organizationCodec)
                , onResponse = OrganizationCreated
                , path = "/organizations/create"
                }
            )

        OrganizationCreated (Ok (Ok organization)) ->
            ( model, Effect.none )

        OrganizationCreated _ ->
            ( model, Effect.none )



-- SUBSCRIPTIONS


subscriptions : Context -> Model -> Subscription Msg
subscriptions { shared, route } model =
    Subscription.onAuthenticationChange AuthenticationChanged



-- VIEW


view : Context -> Model -> Browser.Document Msg
view { shared, route } model =
    { title = "Organization Setup"
    , body =
        [ Html.node "link"
            [ Html.Attributes.rel "stylesheet"
            , Html.Attributes.href "assets/picocss/pico.min.css"
            ]
            []
        , Html.h1 [] [ Html.text "Inventory App" ]
        , Form.view
            { title = "Setup organization"
            , onSubmit = UserSubmittedForm
            , submit = model.submit
            , submitLabel = "Create organization"
            , fields =
                [ { name = "name"
                  , label = "Name"
                  , value = model.name
                  , onInput = UserChangedName
                  , attributes =
                        [ Html.Attributes.disabled (model.submit == Submit.Submitting)
                        ]
                  }
                ]
            }
        ]
    }
