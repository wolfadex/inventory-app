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
import Shared
import Subscription exposing (Subscription)



-- CONTEXT


type alias Context =
    { shared : Shared.Model
    , route : Route ()
    }


type alias Model =
    { layout : Layout.Authenticated.Model
    , items : Response (List Backend.Item)
    }


init : Context -> ( Model, Effect Msg )
init { shared, route } =
    let
        ( layout, layoutEffect ) =
            Layout.Authenticated.init shared route
    in
    ( { layout = layout
      , items = Response.Loading
      }
    , Effect.batch
        [ Effect.map LayoutMessage layoutEffect
        ]
    )



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
view { shared } model =
    Layout.Authenticated.view
        { model = model.layout
        , sharedModel = shared
        , toMsg = LayoutMessage
        , title = "Dashboard"
        , body =
            \{ currentUser } ->
                [ Html.text currentUser.primaryEmail
                , Html.p [] [ Html.text "Lorem ipsum" ]
                ]
        }
