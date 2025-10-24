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



-- module Main exposing (main)
-- import Acadia.Transaction as Transaction
-- import Backend
-- import Browser
-- import Html exposing (Html)
-- import Html.Attributes
-- import Html.Events
-- -- MAIN
-- --
-- -- I do not really like this Elm code!
-- -- My goal is to highlight the functions in the Backend database module.
-- -- So please do not take any of this Elm code as a recommendation!
-- main =
--     Browser.document
--         { init = init
--         , update = update
--         , view = view
--         , subscriptions = always Sub.none
--         }
-- -- MODEL
-- type Model
--     = LandingPage { email : String, password : String }
--     | ProfilePage { food : String, list : List String }
-- init : () -> ( Model, Cmd Msg )
-- init _ =
--     ( LandingPage { email = "", password = "" }
--     , Transaction.attempt "/_endpoints" Loaded Backend.getFoods
--     )
-- -- UPDATE
-- type Msg
--     = GotEmail String
--     | GotPassword String
--     | SignUp
--     | LogIn
--     | LoggedIn (Maybe ())
--       --
--     | GotFood String
--     | Add
--     | Added (Maybe ())
--     | Loaded (Maybe (List String))
--     | LogOut
--     | LoggedOut (Maybe ())
-- update : Msg -> Model -> ( Model, Cmd Msg )
-- update msg model =
--     case msg of
--         GotEmail email ->
--             case model of
--                 LandingPage s ->
--                     ( LandingPage { s | email = email }, Cmd.none )
--                 ProfilePage _ ->
--                     ( model, Cmd.none )
--         GotPassword password ->
--             case model of
--                 LandingPage s ->
--                     ( LandingPage { s | password = password }, Cmd.none )
--                 ProfilePage _ ->
--                     ( model, Cmd.none )
--         SignUp ->
--             ( model
--             , case model of
--                 LandingPage s ->
--                     Transaction.attempt "/_endpoints" LoggedIn (Backend.addUser s.email s.password)
--                 ProfilePage _ ->
--                     Cmd.none
--             )
--         LogIn ->
--             ( model
--             , case model of
--                 LandingPage s ->
--                     Transaction.attempt "/_endpoints" LoggedIn (Backend.login s.email s.password)
--                 ProfilePage _ ->
--                     Cmd.none
--             )
--         LoggedIn result ->
--             case result of
--                 Just () ->
--                     ( LandingPage { email = "", password = "" }
--                     , Transaction.attempt "/_endpoints" Loaded Backend.getFoods
--                     )
--                 Nothing ->
--                     ( model, Cmd.none )
--         GotFood food ->
--             case model of
--                 LandingPage _ ->
--                     ( model, Cmd.none )
--                 ProfilePage s ->
--                     ( ProfilePage { s | food = food }, Cmd.none )
--         Add ->
--             case model of
--                 LandingPage _ ->
--                     ( model, Cmd.none )
--                 ProfilePage s ->
--                     ( model, Transaction.attempt "/_endpoints" Added (Backend.addFood s.food) )
--         Added result ->
--             case result of
--                 Just () ->
--                     case model of
--                         LandingPage _ ->
--                             ( model, Cmd.none )
--                         ProfilePage p ->
--                             ( ProfilePage { food = "", list = p.food :: p.list }, Cmd.none )
--                 Nothing ->
--                     ( LandingPage { email = "", password = "" }
--                     , Cmd.none
--                     )
--         Loaded result ->
--             case result of
--                 Just list ->
--                     ( ProfilePage { food = "", list = list }, Cmd.none )
--                 Nothing ->
--                     ( LandingPage { email = "", password = "" }, Cmd.none )
--         LogOut ->
--             ( model, Transaction.attempt "/_endpoints" LoggedOut Backend.logout )
--         LoggedOut result ->
--             case result of
--                 Just () ->
--                     ( LandingPage { email = "", password = "" }, Cmd.none )
--                 Nothing ->
--                     ( model, Cmd.none )
-- -- VIEW
-- view : Model -> Browser.Document Msg
-- view model =
--     case model of
--         LandingPage { email, password } ->
--             { title = "Log In"
--             , body =
--                 [ Html.input [ Html.Attributes.type_ "email", Html.Attributes.placeholder "Email", Html.Attributes.value email, Html.Events.onInput GotEmail ] []
--                 , Html.input [ Html.Attributes.type_ "password", Html.Attributes.placeholder "Password", Html.Attributes.value password, Html.Events.onInput GotPassword ] []
--                 , Html.input [ Html.Attributes.type_ "button", Html.Attributes.value "Sign Up", Html.Events.onClick SignUp ] []
--                 , Html.input [ Html.Attributes.type_ "button", Html.Attributes.value "Log In", Html.Events.onClick LogIn ] []
--                 ]
--             }
--         ProfilePage { food, list } ->
--             { title = "Foods (" ++ String.fromInt (List.length list) ++ ")"
--             , body =
--                 [ Html.input [ Html.Attributes.type_ "text", Html.Attributes.placeholder "Food", Html.Attributes.value food, Html.Events.onInput GotFood ] []
--                 , Html.input [ Html.Attributes.type_ "button", Html.Attributes.value "Add", Html.Events.onClick Add ] []
--                 , Html.input [ Html.Attributes.type_ "button", Html.Attributes.value "Log Out", Html.Events.onClick LogOut ] []
--                 , Html.ul [] (List.map viewFood list)
--                 ]
--             }
-- viewFood : String -> Html msg
-- viewFood name =
--     Html.li [] [ Html.text name ]
