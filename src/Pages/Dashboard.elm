module Pages.Dashboard exposing (..)

import Backend
import Html exposing (Html)
import Html.Attributes
import Html.Events
import Browser
import Components.Icon
import Effect exposing (Effect)
import Route exposing (Route)
import Shared
import Subscription exposing (Subscription)
import Response exposing (Response)
import Layout.Authenticated


-- CONTEXT


type alias Context =
    { shared : Shared.Model
    , route : Route ()
    }


type alias Model =
    { layout : Layout.Authenticated.Model
    , foods : Response (List Food)
    }

type alias Food =
    ( String )

init : Context -> ( Model, Effect Msg )
init { shared, route } =
    let
        ( layout, layoutEffect ) = Layout.Authenticated.init shared
    in
    ( { layout = layout
      , foods = Response.Loading
      }
    , Effect.batch
        [ Effect.acadia
            { transaction = Backend.getFoods
            , onResponse = GotFoods
            }
        , Effect.map LayoutMessage layoutEffect
        ]
    )


-- SUBSCRIPTIONS


subscriptions : Context -> Model -> Subscription Msg
subscriptions { shared, route } model =
    Layout.Authenticated.subscriptions model.layout
        |> Subscription.map LayoutMessage



-- UPDATE


type Msg
    = LayoutMessage Layout.Authenticated.Msg
    | GotFoods (Maybe (List Food))


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
                }

        GotFoods (Just foods) ->
            ( { model | foods = Response.Success foods }
            , Effect.none
            )

        GotFoods Nothing ->
            ( { model | foods = Response.Failure "Couldn't fetch foods..." }
            , Effect.none
            )



-- view : Backend.User -> Model -> Html Msg
-- view user model =
--     Html.div []
--         [ Html.h1 [] [ Html.text "Inventory App" ]

--         -- , Html.text (user.primaryEmail ++ " logged in")
--         ]

--         -- VIEW


view : Context -> Model -> Browser.Document Msg
view { shared, route } model =
    Layout.Authenticated.view
        { model = model.layout
        , sharedModel = shared
        , toMsg = LayoutMessage
        , title = "Dashboard"
        , body =
            \{ currentUser, currentOrganization } ->
                [ Html.div [ Html.Attributes.class "col align-cx" ]
                    [ Components.Icon.logo 240
                    , Html.h1 [] [ Html.text "Inventory App" ]
                    ]
                ,   Html.text (currentUser.primaryEmail)
                ]
        }