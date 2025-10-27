module Pages.OrganizationInit exposing
    ( Model, Msg
    , init, update, subscriptions, view
    )

{-|

@docs Model, Msg
@docs init, update, subscriptions, view

-}

import Authentication
import Browser
import Dict
import Effect exposing (Effect)
import Form
import Html exposing (Html)
import Html.Attributes
import Html.Events
import Route exposing (Route)
import Icon
import Shared
import Subscription exposing (Subscription)
import Submit exposing (Submit)
import Route.Path
import Backend



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
    | OrganizationCreated (Maybe Backend.Organization)


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
                { transaction = Backend.createOrganization { name = model.name }
                , onResponse = OrganizationCreated
                }
            )

        OrganizationCreated Nothing ->
            ( model, Effect.none )

        OrganizationCreated (Just organization) ->
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
        [ Html.h1 [] [ Html.text "Inventory App" ]
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
