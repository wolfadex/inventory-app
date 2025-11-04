module Layout.Authenticated exposing (..)

import Authentication
import Backend
import Browser
import Dict
import Effect exposing (Effect)
import Html exposing (Html)
import Html.Attributes
import Html.Events
import Icon
import Route exposing (Route)
import Route.Path
import Shared
import Subscription exposing (Subscription)
import Url


type alias AuthContext =
    { currentUser : Backend.User
    , currentOrganization : Backend.Organization
    }



-- INIT


type alias Model =
    ()


init : Shared.Model -> Route params -> ( Model, Effect Msg )
init sharedModel route =
    ( ()
    , case sharedModel.currentUser of
        Authentication.Authenticated _ ->
            case sharedModel.currentOrganization of
                Just _ ->
                    Effect.none

                Nothing ->
                    Effect.navigateTo { path = Route.Path.OrganizationInit, query = Dict.singleton "returnto" (Url.toString route.url) }

        Authentication.Authenticating ->
            Effect.none

        Authentication.Unauthenticated ->
            Effect.navigateTo { path = Route.Path.SignIn, query = Dict.singleton "returnto" (Url.toString route.url) }
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
    , route : Route params
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
                            Effect.none

                        Nothing ->
                            Effect.navigateTo { path = Route.Path.OrganizationInit, query = Dict.singleton "returnto" (Url.toString config.route.url) }

                Authentication.Authenticating ->
                    Effect.none

                Authentication.Unauthenticated ->
                    Effect.navigateTo { path = Route.Path.SignIn, query = Dict.singleton "returnto" (Url.toString config.route.url) }
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
                        viewAuthenticataed
                            { currentUser = user, currentOrganization = organization }
                            (props.body { currentUser = user, currentOrganization = organization })

                    Nothing ->
                        [ Html.h1 [] [ Html.text "TODO: missing current org" ]
                        ]

            Authentication.Authenticating ->
                [ Html.div []
                    [ Icon.loading ]
                ]

            Authentication.Unauthenticated ->
                [ Html.h1 [] [ Html.text "TODO: reauthenticate" ]
                ]
    }


viewAuthenticataed : { currentUser : Backend.User, currentOrganization : Backend.Organization } -> List (Html msg) -> List (Html msg)
viewAuthenticataed context body =
    [ Html.header []
        [ -- Html.h1 [] [ Html.text "Inventory App" ]
          Html.nav []
            [ Html.ul []
                [ Html.li []
                    [ Html.a [ Route.Path.href Route.Path.Dashboard ]
                        [ Html.strong [] [ Html.text "Inventory App" ] ]
                    ]
                ]
            , Html.ul []
                [ Html.li []
                    [ Html.a
                        [ Route.Path.href Route.Path.Dashboard
                        , Html.Attributes.class "secondary"
                        ]
                        [ Html.text "EX: Dash" ]
                    ]
                , Html.li []
                    [ Html.details
                        [ Html.Attributes.class "dropdown" ]
                        [ Html.summary [] [ Html.text context.currentUser.primaryEmail ]
                        , Html.ul [ Html.Attributes.dir "rtl" ]
                            [ Html.li []
                                [ Html.a
                                    [ Route.Path.href Route.Path.Logout
                                    ]
                                    [ Html.text "Logout" ]
                                ]
                            ]
                        ]
                    ]
                ]
            ]
        ]
    , Html.main_ [] body
    ]
