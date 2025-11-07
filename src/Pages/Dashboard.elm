module Pages.Dashboard exposing
    ( Context
    , Model
    , Msg(..)
    , init
    , subscriptions
    , update
    , view
    )

import Backend
import Browser
import Effect exposing (Effect)
import Html
import Layout.Authenticated
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
    { layout : Layout.Authenticated.Model
    , items : Response String (List Backend.Item)
    }


init : Context -> ( Model, Effect Msg )
init { shared, route } =
    Layout.Authenticated.init
        { route = route
        , sharedModel = shared
        , toMsg = LayoutMessage
        , initUnauthenticated =
            \layout ->
                { layout = layout
                , items = Response.Failure ""
                }
        , initAuthenticated =
            \_ layout layoutEffect ->
                ( { layout = layout
                  , items = Response.Loading
                  }
                , Effect.batch
                    [ layoutEffect
                    ]
                )
        }



-- SUBSCRIPTIONS


subscriptions : Context -> Model -> Subscription Msg
subscriptions _ model =
    Layout.Authenticated.subscriptions model.layout
        |> Subscription.map LayoutMessage



-- UPDATE


type Msg
    = LayoutMessage Layout.Authenticated.Msg


update : Context -> Msg -> Model -> ( Model, Effect Msg )
update { shared, route } msg model =
    case msg of
        LayoutMessage layoutMsg ->
            Layout.Authenticated.update
                { msg = layoutMsg
                , toMsg = LayoutMessage
                , model = model.layout
                , toModel = \layout -> { model | layout = layout }
                , sharedModel = shared
                , route = route
                }


view : Context -> Model -> Browser.Document Msg
view { shared, route } model =
    Layout.Authenticated.view
        { model = model.layout
        , sharedModel = shared
        , route = route
        , toMsg = LayoutMessage
        , title = "Dashboard"
        , body =
            \{ currentUser } ->
                [ Html.text currentUser.primaryEmail
                , Html.a [ Route.Path.href Route.Path.Items ] [ Html.text "Items" ]
                ]
        }
