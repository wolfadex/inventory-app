module Layout.Authenticated exposing
    ( AuthContext
    , Model
    , Msg(..)
    , init
    , subscriptions
    , update
    , updateWithAuth
    , view
    )

import Authentication
import Backend
import Browser
import Css
import Dict
import Effect exposing (Effect)
import Html exposing (Html)
import Html.Attributes
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


init :
    { route : Route params
    , sharedModel : Shared.Model
    , toMsg : Msg -> pageMsg
    , initUnauthenticated : Model -> pageModel
    , initAuthenticated : AuthContext -> Model -> Effect pageMsg -> ( pageModel, Effect pageMsg )
    }
    -> ( pageModel, Effect pageMsg )
init props =
    case props.sharedModel.currentUser of
        Authentication.Authenticated user ->
            case props.sharedModel.currentOrganization of
                Just organization ->
                    let
                        ( pageModel, pageEffect ) =
                            props.initAuthenticated
                                { currentUser = user
                                , currentOrganization = organization
                                }
                                ()
                                Effect.none
                    in
                    ( pageModel
                    , pageEffect
                    )

                Nothing ->
                    ( props.initUnauthenticated ()
                    , Effect.navigateTo { path = Route.Path.OrganizationInit, query = Dict.singleton "returnto" (Url.toString props.route.url) }
                    )

        Authentication.Authenticating ->
            ( props.initUnauthenticated ()
            , Effect.none
            )

        Authentication.Unauthenticated ->
            ( props.initUnauthenticated ()
            , Effect.navigateTo { path = Route.Path.Login, query = Dict.singleton "returnto" (Url.toString props.route.url) }
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Subscription Msg
subscriptions _ =
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
                    Effect.navigateTo { path = Route.Path.Login, query = Dict.singleton "returnto" (Url.toString config.route.url) }
            )


updateWithAuth :
    { pageModel : pageModel
    , sharedModel : Shared.Model
    , route : Route params
    , update : AuthContext -> ( pageModel, Effect pageMsg )
    }
    -> ( pageModel, Effect pageMsg )
updateWithAuth config =
    case config.sharedModel.currentUser of
        Authentication.Authenticated user ->
            case config.sharedModel.currentOrganization of
                Just organization ->
                    config.update { currentUser = user, currentOrganization = organization }

                Nothing ->
                    ( config.pageModel, Effect.navigateTo { path = Route.Path.OrganizationInit, query = Dict.singleton "returnto" (Url.toString config.route.url) } )

        Authentication.Authenticating ->
            ( config.pageModel, Effect.none )

        Authentication.Unauthenticated ->
            ( config.pageModel, Effect.navigateTo { path = Route.Path.Login, query = Dict.singleton "returnto" (Url.toString config.route.url) } )



-- VIEW


view :
    { model : Model
    , route : Route params
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
                            props.route
                            { currentUser = user, currentOrganization = organization }
                            (props.body { currentUser = user, currentOrganization = organization })

                    Nothing ->
                        [ Html.h1 [] [ Html.text "TODO: missing current org" ]
                        ]

            Authentication.Authenticating ->
                [ Html.div []
                    [ Icon.loading 64 ]
                ]

            Authentication.Unauthenticated ->
                [ Html.h1 [] [ Html.text "TODO: reauthenticate" ]
                ]
    }


viewAuthenticataed : Route params -> { currentUser : Backend.User, currentOrganization : Backend.Organization } -> List (Html msg) -> List (Html msg)
viewAuthenticataed route context body =
    [ Html.div [ Css.pageFull ]
        [ Html.header []
            [ Html.nav []
                [ Html.ul []
                    [ Html.li []
                        [ Html.a
                            [ Route.Path.href Route.Path.Dashboard
                            ]
                            [ Icon.logo 32
                            , Html.strong [ Html.Attributes.style "margin-left" "0.5rem" ] [ Html.text context.currentOrganization.name ]
                            ]
                        ]
                    ]
                , Html.ul []
                    [ viewNavLink route Route.Path.Items "Items"
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
    ]


viewNavLink : Route params -> Route.Path.Path -> String -> Html msg
viewNavLink route path label =
    Html.li []
        [ Html.a
            [ Route.Path.href path
            , Html.Attributes.class "secondary"
            , if path == route.path then
                Html.Attributes.attribute "aria-current" "page"

              else
                Html.Attributes.class ""
            ]
            [ Html.text label ]
        ]
