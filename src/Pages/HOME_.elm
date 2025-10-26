module Pages.HOME_ exposing (..)

import Backend
import Html exposing (Html)
import Html.Attributes
import Html.Events
import Browser
import Icon
import Effect exposing (Effect)
import Route exposing (Route)
import Shared
import Subscription exposing (Subscription)
import Response exposing (Response)


-- CONTEXT


type alias Context =
    { shared : Shared.Model
    , route : Route ()
    }


type alias Model =
    { foods : Response (List Food)
    }

type alias Food =
    ( String )

init : Context -> ( Model, Effect Msg )
init { shared, route } =
    ( { foods = Response.Loading }
    , Effect.acadia
        { transaction = Backend.getFoods
        , onResponse = GotFoods
        }
    )


-- SUBSCRIPTIONS


subscriptions : Context -> Model -> Subscription Msg
subscriptions { shared, route } model =
    Subscription.none



-- UPDATE


type Msg
    = GotFoods (Maybe (List Food))


update : Context -> Msg -> Model -> ( Model, Effect Msg )
update { shared, route } msg model =
    case msg of
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
    { title = "Homepage"
    , body =
        [ Html.div [ Html.Attributes.class "col align-cx" ]
            [ Icon.logo 240
            , Html.h1 [] [ Html.text "Welcome to Elm Land!" ]
            ]
        , Html.p [] [ Html.text (Debug.toString model) ]
        ]
    }