module Pages.OrganizationInit exposing
    ( Model, Msg
    , init, update, subscriptions, view
    , Context
    )

{-|

@docs Model, Msg
@docs init, update, subscriptions, view

-}

import Authentication
import Backend
import Browser
import Css
import Dict
import Effect exposing (Effect)
import Endpoints.ApiOrganizations
import Html
import Html.Attributes
import Http.Extended
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
    { name : String
    , submit : Submit String Http.Extended.Error
    }


init : Context -> ( Model, Effect Msg )
init { shared } =
    ( { name = ""
      , submit = Submit.Fresh
      }
    , case shared.currentUser of
        Authentication.Unauthenticated ->
            Effect.routeTo { path = Route.Path.Login, query = Dict.empty }

        Authentication.Authenticating ->
            Effect.none

        Authentication.Authenticated _ ->
            Effect.none
    )



-- UPDATE


type Msg
    = UserChangedName String
    | UserSubmittedForm
    | AuthenticationChanged
    | OrganizationCreated (Result Http.Extended.Error Backend.Organization)


update : Context -> Msg -> Model -> ( Model, Effect Msg )
update { shared } msg model =
    case msg of
        AuthenticationChanged ->
            ( model
            , case shared.currentUser of
                Authentication.Authenticated _ ->
                    Effect.none

                Authentication.Authenticating ->
                    Effect.none

                Authentication.Unauthenticated ->
                    Effect.routeTo { path = Route.Path.Login, query = Dict.empty }
            )

        UserChangedName name ->
            ( { model | name = name }
            , Effect.none
            )

        UserSubmittedForm ->
            ( model
            , Endpoints.ApiOrganizations.post OrganizationCreated
                { name = model.name
                }
            )

        OrganizationCreated (Ok _) ->
            ( model, Effect.none )

        OrganizationCreated (Err _) ->
            ( model, Effect.none )



-- SUBSCRIPTIONS


subscriptions : Context -> Model -> Subscription Msg
subscriptions _ _ =
    Subscription.onAuthenticationChange AuthenticationChanged



-- VIEW


view : Context -> Model -> Browser.Document Msg
view _ model =
    { title = "Organization Setup"
    , body =
        [ Html.main_ [ Css.pageCentered ]
            [ Html.header
                []
                [ Html.strong [ Html.Attributes.style "font-size" "3rem" ] [ Html.text "Inventory App" ]
                ]
            , Html.article []
                [ Ui.Form.view
                    { name = "organization"
                    , title = "Setup organization"
                    , onSubmit = UserSubmittedForm
                    , additionalButtons = []
                    , submit = model.submit
                    , submitLabel = "Create organization"
                    , fields =
                        [ Ui.TextInput.basic
                            { name = "name"
                            , label = "Name"
                            , value = model.name
                            , onInput = UserChangedName
                            , submit = model.submit
                            }
                            [ Html.Attributes.disabled (model.submit == Submit.Submitting)
                            ]
                        ]
                    }
                ]
            ]
        ]
    }
