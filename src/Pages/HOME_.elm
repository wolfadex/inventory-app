module Pages.HOME_ exposing (..)

import Backend
import Browser
import Css
import Effect exposing (Effect)
import Html exposing (Html)
import Html.Attributes
import Html.Events
import Icon
import Response exposing (Response)
import Route exposing (Route)
import Route.Path
import Shared
import Subscription exposing (Subscription)



-- CONTEXT


type alias Context =
    { shared : Shared.Model
    , route : Route ()
    }


type alias Model =
    {}


init : Context -> ( Model, Effect Msg )
init _ =
    ( {}
    , Effect.none
    )



-- SUBSCRIPTIONS


subscriptions : Context -> Model -> Subscription Msg
subscriptions _ _ =
    Subscription.none



-- UPDATE


type Msg
    = NoOp


update : Context -> Msg -> Model -> ( Model, Effect Msg )
update _ msg model =
    case msg of
        NoOp ->
            ( model
            , Effect.none
            )


view : Context -> Model -> Browser.Document Msg
view _ _ =
    { title = "Welcome"
    , body =
        [ Html.header []
            [ Icon.logo 100
            , Html.h1 [] [ Html.text "Inventory App" ]
            ]
        , Html.main_
            [ Html.Attributes.class "container"
            , Css.pageMarketing
            ]
            [ Html.p [] [ Html.text "A one stop shop for managing what you have and where it is." ]
            , Html.span []
                [ Html.a
                    [ Route.Path.href Route.Path.Login ]
                    [ Html.text "Login" ]
                , Html.text " or "
                , Html.a
                    [ Route.Path.href Route.Path.SignUp ]
                    [ Html.text "Sign Up!" ]
                ]
            ]
        ]
    }
