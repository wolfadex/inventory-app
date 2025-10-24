module Main exposing (..)

import Backend
import Browser
import Browser.Navigation
import Html exposing (Html)
import Html.Attributes
import Html.Events
import Page exposing (Page)
import Page.Home
import Page.Login
import Route exposing (Route)
import Url exposing (Url)


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        , onUrlRequest = UrlRequested
        , onUrlChange = UrlChanged
        }


type alias Model =
    { navKey : Browser.Navigation.Key
    , page : Page
    , authentication : Authentication
    }


type Authentication
    = Unauthenticated
    | Authenticated Backend.User


init : () -> Url -> Browser.Navigation.Key -> ( Model, Cmd Msg )
init () url navKey =
    let
        initialRoute =
            Route.fromUrl url
                |> Maybe.withDefault Route.Login

        ( page, cmd ) =
            initPage initialRoute
    in
    ( { navKey = navKey
      , page = page
      , authentication = Unauthenticated
      }
    , cmd
    )


initPage : Route -> ( Page, Cmd Msg )
initPage route =
    case route of
        Route.Login ->
            Page.Login.init ()
                |> Tuple.mapBoth Page.Login (Cmd.map (Page.LoginMsg >> PageMsg))

        Route.Home ->
            Page.Home.init ()
                |> Tuple.mapBoth Page.Home (Cmd.map (Page.HomeMsg >> PageMsg))


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


type Msg
    = UrlRequested Browser.UrlRequest
    | UrlChanged Url
    | PageMsg Page.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UrlRequested urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model
                    , Browser.Navigation.pushUrl model.navKey (Url.toString url)
                    )

                Browser.External href ->
                    ( model
                    , Browser.Navigation.load href
                    )

        UrlChanged url ->
            let
                initialRoute =
                    Route.fromUrl url
                        |> Maybe.withDefault Route.Login

                ( page, cmd ) =
                    initPage initialRoute
            in
            ( { model | page = page }
            , cmd
            )

        PageMsg pageMsg ->
            updatePage pageMsg model


updatePage : Page.Msg -> Model -> ( Model, Cmd Msg )
updatePage pageMsg model =
    case pageMsg of
        Page.LoginMsg loginMsg ->
            case model.page of
                Page.Login loginModel ->
                    Page.Login.update
                        { msg = loginMsg
                        , model = loginModel
                        , toMsg = Page.LoginMsg >> PageMsg
                        , toModel = \pageModel -> { model | page = Page.Login pageModel }
                        , authenticated = \user ( m, cmd ) -> ( { m | authentication = Authenticated user }, cmd )
                        }

                _ ->
                    ( model, Cmd.none )

        Page.HomeMsg homeMsg ->
            case model.page of
                Page.Home homeModel ->
                    Page.Home.update
                        { msg = homeMsg
                        , model = homeModel
                        , toMsg = Page.HomeMsg >> PageMsg
                        , toModel = \pageModel -> { model | page = Page.Home pageModel }
                        }

                _ ->
                    ( model, Cmd.none )


view : Model -> Browser.Document Msg
view model =
    { title = "My App - Login"
    , body =
        [ case model.page of
            Page.Login pageModel ->
                Page.Login.view pageModel
                    |> Html.map (Page.LoginMsg >> PageMsg)

            Page.Home pageModel ->
                case model.authentication of
                    Authenticated user ->
                        Page.Home.view user pageModel
                            |> Html.map (Page.HomeMsg >> PageMsg)

                    Unauthenticated ->
                        viewUnauthenticated
        ]
    }


viewUnauthenticated : Html Msg
viewUnauthenticated =
    Html.div
        []
        [ Html.h2 [] [ Html.text "Inventory App" ]
        , Html.a
            [ Html.Attributes.href (Route.toString Route.Login)
            ]
            [ Html.text "Login" ]
        ]
