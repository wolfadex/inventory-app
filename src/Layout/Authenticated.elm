module Layout.Authenticated exposing (..)


import Authentication
import Backend
import Html exposing (Html)
import Html.Attributes
import Html.Events
import Browser
import Components.Icon
import Effect exposing (Effect)
import Route exposing (Route)
import Route.Path
import Shared
import Subscription exposing (Subscription)
import Response exposing (Response)


type alias AuthContext =
    { currentUser : Backend.User
    , currentOrganization : Backend.Organization
    }

-- INIT

type alias Model =
    ()

init : Shared.Model -> ( Model, Effect Msg )
init sharedModel =
    ( ()
    , Debug.log "init" <| case sharedModel.currentUser of
        Authentication.Authenticated _ ->
            case sharedModel.currentOrganization of
                Just _ ->
                    ( Effect.none )

                Nothing ->
                    ( Effect.navigateTo Route.Path.OrganizationInit )

        Authentication.Authenticating ->
            ( Effect.none )

        Authentication.Unauthenticated ->
            ( Effect.navigateTo Route.Path.SignIn )
    )


-- SUBSCRIPTIONS

subscriptions : Model -> Subscription Msg
subscriptions model =
    Subscription.onAuthenticationChange AuthenticationChanged


-- UPDATE

type Msg
    = AuthenticationChanged

update :
    { msg : Msg
    , model : Model
    , sharedModel : Shared.Model
    , toModel : Model -> pageModel
    , toMsg : Msg -> pageMsg
    }
    -> ( pageModel, Effect pageMsg )
update ({ model } as config) =
    case config.msg of
        AuthenticationChanged ->
            ( config.toModel model
            , case config.sharedModel.currentUser of
                Authentication.Authenticated _ ->
                    case config.sharedModel.currentOrganization of
                        Just _ ->
                            ( Effect.none )

                        Nothing ->
                            ( Effect.navigateTo Route.Path.OrganizationInit )

                Authentication.Authenticating ->
                    ( Effect.none )

                Authentication.Unauthenticated ->
                    ( Effect.navigateTo Route.Path.SignIn )
            )


-- VIEW

view :
    { model : Model
    , sharedModel : Shared.Model
    , toMsg : Msg -> pageMsg
    , title : String
    , body : AuthContext -> List (Html pageMsg)
    }
    -> Browser.Document pageMsg
view props =
    { title = props.title
    , body =
        case props.sharedModel.currentUser of
            Authentication.Authenticated user ->
                case props.sharedModel.currentOrganization of
                    Just organization ->
                        props.body { currentUser = user, currentOrganization = organization }

                    Nothing ->
                        [ Html.h1 [] [ Html.text "TODO: missing current org" ]
                        ]

            Authentication.Authenticating ->
                [ Html.h1 [] [ Html.text "Loading..." ]
                ]

            Authentication.Unauthenticated ->
                [ Html.h1 [] [ Html.text "TODO: reauthenticate" ]
                ]
    }
